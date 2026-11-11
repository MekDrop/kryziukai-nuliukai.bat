import { mkdir, readFile, writeFile } from 'node:fs/promises';
import Mustache from 'mustache';
import { loadLocales } from './locales.mjs';

const latestReleaseZipUrl = process.env.latestReleaseZipUrl;
if (!/^https:\/\/api\.github\.com\/repos\/MekDrop\/kryziukai-nuliukai\.bat\/zipball\/[a-zA-Z0-9._~/%-]+$/.test(latestReleaseZipUrl || '')) {
    throw new Error('latestReleaseZipUrl must be a GitHub release archive URL for this repository.');
}

const template = await readFile(new URL('./index.html.mustache', import.meta.url), 'utf8');
await mkdir('dist', { recursive: true });
for (const locale of await loadLocales()) {
    const html = Mustache.render(template, {
        ...locale,
        latestReleaseZipUrl,
        // This is inserted into a script, so prevent text from closing that tag.
        runtimeText: JSON.stringify(locale.ui).replaceAll('<', '\\u003c'),
    });
    if (/{{[\s\S]*?}}/.test(html)) throw new Error(`Unresolved template value in ${locale.filename}`);
    await writeFile(`dist/${locale.filename}`, html);
    console.log(`Rendered ${locale.filename} (${locale.language}).`);
}
