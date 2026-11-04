import { test } from 'node:test';
import assert from 'node:assert/strict';
import { gameFloppy } from './floppy.mjs';

test('FAT12 image preserves files across cluster boundaries and has matching FATs', () => {
    const game = Buffer.from('echo game\r\n'.repeat(170));
    const language = Buffer.from('key,value\r\n'.repeat(90));
    const lithuanian = Buffer.from('difficulty.prompt,Pasirink sunkuma [1-3]:\r\n');
    const ansi = { exe: Buffer.alloc(13312, 0x4d), dll: Buffer.alloc(46592, 0x5a), license: Buffer.from('ANSI license') };
    const disk = gameFloppy(game, language, Buffer.from('license'), lithuanian, lithuanian, ansi);
    assert.equal(disk.length, 1474560);
    assert.equal(disk.readUInt16LE(510), 0xaa55);
    assert.deepEqual(disk.subarray(512, 5120), disk.subarray(5120, 9728));
    function readFile(entry) {
        const chunks = [];
        let cluster = disk.readUInt16LE(entry + 26);
        const visited = new Set();
        while (cluster < 0xff8) {
            assert.ok(cluster >= 2 && !visited.has(cluster));
            visited.add(cluster);
            chunks.push(disk.subarray((31 + cluster) * 512, (32 + cluster) * 512));
            const packed = disk.readUInt16LE(512 + Math.floor(cluster * 1.5));
            cluster = cluster & 1 ? packed >> 4 : packed & 0xfff;
        }
        return Buffer.concat(chunks).subarray(0, disk.readUInt32LE(entry + 28));
    }
    const root = 19 * 512;
    assert.deepEqual(readFile(root + 32), game);
    const directory = (31 + disk.readUInt16LE(root + 26)) * 512;
    assert.equal(disk.toString('ascii', directory + 64, directory + 75), 'EN      CSV');
    assert.deepEqual(readFile(directory + 64), language);
    assert.deepEqual(readFile(directory + 96), lithuanian);
    assert.equal(disk.toString('ascii', directory + 128, directory + 139), 'LT      TXT');
    assert.deepEqual(readFile(directory + 128), lithuanian);
    assert.deepEqual(readFile(root + 5 * 32), ansi.exe);
    assert.deepEqual(readFile(root + 6 * 32), ansi.dll);
    assert.deepEqual(readFile(root + 7 * 32), ansi.license);
    assert.match(readFile(root + 64).toString(), /A:\\kryz\.bat \/ASCII \/MONO/);
    assert.match(readFile(root + 64).toString(), /A:\\kryz\.bat \/ASCII \/COLOR/);
    assert.match(readFile(root + 64).toString(), /set "game_language=en"/);
});

test('oversized input cannot overwrite floppy metadata or grow the image', () => {
    assert.throws(() => gameFloppy(Buffer.alloc(1474560), Buffer.alloc(1), Buffer.alloc(1)), /capacity/);
});
