import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { renderReleaseLink } from './release.mjs';

test('page template renders a static ZIP link for the latest release', async () => {
    const template = await readFile(new URL('../web/index.html', import.meta.url), 'utf8');
    const page = await renderReleaseLink(template, async url => {
        assert.equal(url, 'https://api.github.com/repos/MekDrop/kryziukai-nuliukai.bat/releases/latest');
        return { ok: true, json: async () => ({ tag_name: 'v3.0/test' }) };
    });
    assert.ok(page.includes('href="https://github.com/MekDrop/kryziukai-nuliukai.bat/archive/refs/tags/v3.0%2Ftest.zip"'));
    assert.ok(!page.includes('{{LATEST_RELEASE_ZIP_URL}}'));
    assert.ok(!page.includes('api.github.com'));
});

test('release lookup failures stop page generation', async () => {
    await assert.rejects(renderReleaseLink('', async () => ({ ok: false, status: 403 })), /HTTP 403/);
    await assert.rejects(renderReleaseLink('', async () => ({ ok: true, json: async () => ({}) })), /no tag name/);
    await assert.rejects(renderReleaseLink('', async () => { throw new Error('offline'); }), /offline/);
});
