// Deployment requires real previews; template tests can skip image-file checks.
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { readFile } from 'node:fs/promises';
import { loadLocales, siteUrl } from './locales.mjs';

const args = process.argv.slice(2);
const language = args.find(arg => !arg.startsWith('--'));
const skipPreviewImages = args.includes('--skip-preview-images');

for (const locale of await loadLocales(language)) {
    const html = await readFile(`dist/${locale.filename}`, 'utf8');
    assert(html.includes(`<html lang="${locale.language}">`), `${locale.filename}: wrong document language`);
    assert(html.includes(`<link rel="canonical" href="${siteUrl}">`), `${locale.filename}: missing English canonical`);
    for (const [language, url] of [['en', siteUrl], ['lt', new URL('lt.html', siteUrl).href], ['x-default', siteUrl]]) {
        assert(html.includes(`<link rel="alternate" hreflang="${language}" href="${url}">`), `${locale.filename}: missing ${language} alternate`);
    }
    assert(html.includes(`<meta property="og:url" content="${locale.pageUrl}">`), `${locale.filename}: wrong sharing URL`);
    assert(html.includes(`<meta property="og:locale" content="${locale.ogLocale}">`), `${locale.filename}: wrong sharing locale`);
    assert(!/{{[\s\S]*?}}/.test(html), `${locale.filename}: unresolved template data`);
    const imageUrl = html.match(/<meta property="og:image" content="([^"]+)">/)?.[1];
    assert(imageUrl, `${locale.filename}: missing sharing image`);
    assert.equal(html.match(/<meta name="twitter:image" content="([^"]+)">/)?.[1], imageUrl);
    const filename = new URL(imageUrl).pathname.split('/').pop();
    assert.equal(imageUrl, new URL(filename, siteUrl).href, `${locale.filename}: wrong image host`);
    if (skipPreviewImages) {
        assert.equal(imageUrl, locale.previewImageUrl, `${locale.filename}: wrong template sharing image`);
        console.log(`Validated ${locale.filename} without generating a sharing image.`);
        continue;
    }
    assert(new RegExp(`^og-game-${locale.language}-[a-f0-9]{16}\\.png$`).test(filename), `${locale.filename}: missing generated ${locale.language} preview`);
    const png = await readFile(`dist/${filename}`);
    assert.equal(png.subarray(0, 8).toString('hex'), '89504e470d0a1a0a');
    assert.equal(png.readUInt32BE(16), 1200);
    assert.equal(png.readUInt32BE(20), 630);
    assert(filename.includes(createHash('sha256').update(png).digest('hex').slice(0, 16)), `${locale.filename}: image hash mismatch`);
    console.log(`Validated ${locale.filename} and ${filename}.`);
}
