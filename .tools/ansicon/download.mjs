import { createHash } from 'node:crypto';
import { mkdir, writeFile } from 'node:fs/promises';
import { basename } from 'node:path';
import { unzipSync } from 'fflate';

const url = 'https://github.com/adoxa/ansicon/releases/download/v1.84/ansi184-bin.zip';
const archiveHash = '84a40f77f46162d85d0e4275f2956259897d771d1722ef333e5e0efea22de6f0';
const hashes = {
    'x86/ansicon.exe': '7b78124871239696d9b0472d6c4411dc69f388bcbde3c5e297dade41f6a1629a',
    'x86/ANSI32.dll': 'ba0ec3831a1a5baf669c6e1f1bd01415895677272aa01e099b97f62dfb8d07b5',
};
const sha256 = data => createHash('sha256').update(data).digest('hex');
const response = await fetch(url);
if (!response.ok) throw new Error(`ANSICON download failed: HTTP ${response.status}`);
const archive = Buffer.from(await response.arrayBuffer());
if (sha256(archive) !== archiveHash) throw new Error('ANSICON archive checksum mismatch');
const needed = new Set([...Object.keys(hashes), 'LICENSE.txt']);
const files = unzipSync(archive, { filter: file => needed.has(file.name) });
for (const name of needed) {
    if (!files[name]) throw new Error(`Missing ANSICON file: ${name}`);
    if (hashes[name] && sha256(files[name]) !== hashes[name]) throw new Error(`ANSICON checksum mismatch: ${name}`);
}
const output = new URL('./bin/', import.meta.url);
await mkdir(output, { recursive: true });
for (const name of needed) await writeFile(new URL(basename(name), output), files[name]);
console.log('Downloaded and verified ANSICON 1.84 (x86).');
