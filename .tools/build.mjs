import { mkdir, readFile, writeFile, copyFile } from 'node:fs/promises';
import { gameFloppy } from './floppy.mjs';
import { renderReleaseLink } from './release.mjs';
const page = await renderReleaseLink(await readFile('web/index.html', 'utf8'));
await mkdir('dist/vendor', { recursive: true });
await writeFile('dist/index.html', page);
await copyFile('web/favicon.ico', 'dist/favicon.ico');
for (const file of ['libv86.mjs', 'v86.wasm']) await copyFile(`node_modules/v86/build/${file}`, `dist/vendor/${file}`);
await copyFile('node_modules/v86/LICENSE', 'dist/vendor/LICENSE');
// npm's v86 package does not include BIOS files.
const revision = '315b2b0b758703ef0e6cc7b4088d6068f83f3c20';
for (const file of ['seabios.bin', 'vgabios.bin', 'COPYING.LESSER', 'fetch-and-build-seabios.sh', 'seabios.config']) {
    const response = await fetch(`https://raw.githubusercontent.com/copy/v86/${revision}/bios/${file}`);
    if (!response.ok) throw new Error(`Firmware download failed: ${file}: ${response.status}`);
    await writeFile(`dist/vendor/${file}`, Buffer.from(await response.arrayBuffer()));
}
await writeFile('dist/vendor/BIOS-LICENSE.txt', 'SeaBIOS and VGA BIOS: see COPYING.LESSER. Firmware and build recipe: https://github.com/copy/v86/tree/' + revision + '/bios\nSeaBIOS source: https://github.com/coreboot/seabios\n');
const crlf = bytes => Buffer.from(bytes.toString('utf8').replace(/\r?\n/g, '\r\n'));
const lithuanian = crlf(await readFile('Language/lt.csv'));
// Windows 2000's console cannot reliably read the UTF-8 translation. Preserve
// its wording in a generated ASCII fallback, leaving the source CSV untouched.
const asciiLithuanian = Buffer.from(lithuanian.toString('utf8').normalize('NFD').replace(/\p{M}/gu, ''), 'utf8');
if (asciiLithuanian.some(byte => byte > 127)) throw new Error('Legacy Lithuanian translation contains non-ASCII characters');
const ansi = {
    exe: await readFile(new URL(import.meta.resolve('@kryz/ansicon/ansicon.exe'))),
    dll: await readFile(new URL(import.meta.resolve('@kryz/ansicon/ANSI32.dll'))),
    license: await readFile(new URL(import.meta.resolve('@kryz/ansicon/LICENSE.txt'))),
};
await writeFile('dist/vendor/ANSICON-LICENSE.txt', ansi.license);
await writeFile('dist/game.img', gameFloppy(crlf(await readFile('kryz.bat')), crlf(await readFile('Language/en.csv')), await readFile('License.txt'), lithuanian, asciiLithuanian, ansi));
await writeFile('dist/.nojekyll', '');
console.log("Built slim v86 page with the Windows 2000 demo.");
