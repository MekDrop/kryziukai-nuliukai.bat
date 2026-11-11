// Build-time only: run the freshly built VM, play a move, and publish its pixels.
import { createHash } from 'node:crypto';
import { createServer } from 'node:http';
import { readFile, writeFile, mkdir } from 'node:fs/promises';
import { resolve, sep, extname } from 'node:path';
import { setTimeout as sleep } from 'node:timers/promises';
import { chromium } from 'playwright';
import { createWorker } from 'tesseract.js';
import english from '@tesseract.js-data/eng';
import Mustache from 'mustache';
import { loadLocales } from './locales.mjs';

const root = resolve('dist');
const requestedLanguage = process.argv[2] || 'all';
const locales = (await loadLocales()).filter(locale => requestedLanguage === 'all' || locale.language === requestedLanguage);
if (!locales.length) throw new Error('Capture language must be en, lt, or all.');
const types = { '.html': 'text/html', '.mjs': 'text/javascript', '.wasm': 'application/wasm', '.png': 'image/png' };
const server = createServer(async (request, response) => {
    try {
        const pathname = decodeURIComponent(new URL(request.url, 'http://localhost').pathname);
        const file = resolve(root, `.${pathname === '/' ? '/index.html' : pathname}`);
        if (!file.startsWith(`${root}${sep}`)) {
            response.writeHead(403).end();
            return;
        }
        const body = await readFile(file);
        response.writeHead(200, { 'Content-Type': types[extname(file)] || 'application/octet-stream' }).end(body);
    } catch {
        response.writeHead(404).end();
    }
});

let browser;
let page;
let worker;
let lastText = '';
let loadError;
let diagnostics = resolve('.cache/preview', locales[0].language);
const messages = [];
await mkdir(diagnostics, { recursive: true });
// Also bound operations such as a stuck guest download or OCR worker startup.
const watchdog = setTimeout(() => {
    console.error('Preview capture exceeded its twelve-minute deadline.');
    process.exit(1);
}, 12 * 60_000);

try {
    await new Promise((done, reject) => {
        server.once('error', reject);
        server.listen(0, '127.0.0.1', done);
    });
    browser = await chromium.launch({ headless: true, args: ['--disable-dev-shm-usage'] });
    // The Windows 2000 game uses ASCII Lithuanian, which the bundled English
    // recognition data also reads. OCR never calls an external service.
    worker = await createWorker('eng', 1, { langPath: english.langPath, gzip: true, cacheMethod: 'none' });
    await worker.setParameters({ tessedit_pageseg_mode: '11' });

    for (const locale of locales) {
        diagnostics = resolve('.cache/preview', locale.language);
        await mkdir(diagnostics, { recursive: true });
        await writeFile(resolve(diagnostics, 'errors.txt'), '');
        lastText = '';
        loadError = undefined;
        messages.length = 0;
        const html = await readFile(resolve(root, locale.filename), 'utf8');
        const imagePattern = new RegExp(`https://mekdrop\\.github\\.io/kryziukai-nuliukai\\.bat/og-game-${locale.language}(?:-[a-f0-9]{16})?\\.png`, 'g');
        if (html.match(imagePattern)?.length !== 2) throw new Error(`Render ${locale.filename} before generating its preview.`);
        const targetUrl = `http://127.0.0.1:${server.address().port}/${locale.filename}`;
        page = await browser.newPage({ viewport: { width: 1600, height: 1000 }, deviceScaleFactor: 1 });
        page.setDefaultTimeout(30_000);
        page.on('pageerror', error => {
            messages.push(error.message);
            loadError = error;
        });
        page.on('requestfailed', request => {
            const message = `${request.url()}: ${request.failure()?.errorText}`;
            messages.push(message);
            loadError = new Error(message);
        });
        page.on('response', response => {
            if (response.status() >= 400) {
                loadError = new Error(`Machine asset HTTP ${response.status()}: ${response.url()}`);
                messages.push(loadError.message);
            }
        });
        await page.goto(targetUrl, { waitUntil: 'domcontentloaded' });
        await page.locator('#app').waitFor({ state: 'visible' });

        async function readScreen() {
            const frame = await page.locator('#screen_container canvas').evaluate(canvas => {
                // Read the native guest resolution, independent of the website's scaling.
                const pixels = canvas.getContext('2d').getImageData(0, 0, canvas.width, canvas.height).data;
                let cyan = 0;
                let magenta = 0;
                for (let i = 0; i < pixels.length; i += 4) {
                    if (pixels[i] < 100 && pixels[i + 1] > 110 && pixels[i + 2] > 110) cyan++;
                    if (pixels[i] > 110 && pixels[i + 1] < 100 && pixels[i + 2] > 110) magenta++;
                }
                return { data: canvas.toDataURL('image/png'), cyan, magenta };
            });
            const png = Buffer.from(frame.data.split(',')[1], 'base64');
            const { data: { text } } = await worker.recognize(png);
            lastText = text;
            await writeFile(resolve(diagnostics, 'guest.png'), png);
            await writeFile(resolve(diagnostics, 'guest.txt'), text);
            return { ...frame, text };
        }

        async function waitForScreen(label, predicate, timeout = 120_000) {
            console.log(`[${locale.language}] Waiting for ${label}...`);
            const deadline = Date.now() + timeout;
            while (Date.now() < deadline) {
                if (loadError) throw loadError;
                const status = await page.locator('#status').textContent();
                if (status.startsWith(locale.ui.failed)) throw new Error(status);
                const frame = await readScreen();
                if (predicate(frame)) return frame;
                await sleep(2500);
            }
            throw new Error(`Timed out waiting for ${label}. Last recognized screen:\n${lastText}`);
        }

        const contains = (frame, phrase) => frame.text.replace(/\s+/g, ' ').toLowerCase().includes(phrase.toLowerCase());
        await waitForScreen('the Windows 2000 difficulty prompt', frame => contains(frame, locale.preview.difficultyPrompt));
        await page.locator('#screen_container').focus();
        await page.keyboard.press('Digit2');
        await page.keyboard.press('Enter');
        const isBoard = frame => /TIC\s+TAC\s+TOE/i.test(frame.text) && contains(frame, locale.preview.turn) && contains(frame, locale.preview.choose);
        const emptyBoard = await waitForScreen('the game board', isBoard);
        await page.keyboard.press('Digit5');
        await page.keyboard.press('Enter');
        // The initial board already has colored headings. Require NEW cyan and
        // magenta pixels, plus a visible move prompt, to prove both players moved.
        const played = await waitForScreen('a board with X and O', frame =>
            isBoard(frame) && frame.cyan > emptyBoard.cyan + 20 && frame.magenta > emptyBoard.magenta + 20);

        // Compose a sharing card around the actual captured guest, without cropping
        // away its Windows title bar or taskbar. No screenshot is checked into Git.
        const card = await browser.newPage({ viewport: { width: 1200, height: 630 }, deviceScaleFactor: 1 });
        await card.setContent(`<!doctype html><html lang="${locale.language}"><meta charset="utf-8"><style>
            * { box-sizing: border-box; }
            body { margin: 0; width: 1200px; height: 630px; background: #008080; color: white; font-family: Arial, sans-serif; }
            aside { position: absolute; left: 36px; top: 44px; width: 312px; }
            .tag { font: bold 14px monospace; letter-spacing: 2px; color: #b5ffff; }
            h1 { margin: 25px 0; height: 250px; display: flex; flex-direction: column; justify-content: center; font-size: ${locale.isLithuanian ? 46 : 88}px; line-height: ${locale.isLithuanian ? 1.15 : .94}; letter-spacing: ${locale.isLithuanian ? -2 : -6}px; }
            p { font-size: 22px; line-height: 1.4; margin: 0; }
            footer { position: absolute; left: 36px; bottom: 32px; font: 14px monospace; color: #b5ffff; }
            img { position: absolute; right: 24px; top: 22px; width: 780px; height: 585px; box-shadow: 8px 8px 0 #005656; }
        </style><aside><div class="tag">KRYZIUKAI-NULIUKAI.BAT</div><h1>${locale.preview.heading.map(line => `<span>${Mustache.escape(line)}</span>`).join('')}</h1><p>${locale.preview.description.map(Mustache.escape).join('<br>')}</p></aside>
        <footer>${Mustache.escape(locale.preview.footer)}</footer><img alt="${Mustache.escape(locale.imageAlt)}" src="${played.data}"></html>`);
        await card.locator('img').evaluate(image => image.decode());
        const png = await card.screenshot({ type: 'png' });
        const filename = `og-game-${locale.language}-${createHash('sha256').update(png).digest('hex').slice(0, 16)}.png`;
        await writeFile(resolve(root, filename), png);
        // The static HTML must contain absolute URLs: sharing crawlers need neither
        // JavaScript nor a running emulator. A content hash gives new images new URLs.
        const updatedHtml = html.replaceAll(imagePattern, new URL(filename, locale.previewImageUrl).href);
        if (updatedHtml.includes(locale.previewImageUrl)) throw new Error('Preview metadata was not updated.');
        await writeFile(resolve(root, locale.filename), updatedHtml);
        await card.close();
        await page.close();
        page = undefined;
        console.log(`Generated ${filename} (1200 × 630) from the running Windows 2000 game.`);
    }
} catch (error) {
    if (diagnostics) {
        if (page) await page.screenshot({ path: resolve(diagnostics, 'page.png') }).catch(() => {});
        await writeFile(resolve(diagnostics, 'errors.txt'), [String(error), ...messages].join('\n'));
    }
    throw error;
} finally {
    await worker?.terminate();
    await browser?.close();
    await new Promise(done => server.close(done));
    clearTimeout(watchdog);
}
