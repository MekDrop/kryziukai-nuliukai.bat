// Minimal FAT12 writer for a standard 1.44 MiB floppy; no build dependencies.
export function gameFloppy(game, english, license, lithuanian, asciiLithuanian, ansi) {
    const disk = Buffer.alloc(1474560);
    disk.set([0xeb, 0x3c, 0x90]);
    disk.write('KRYZ    ', 3, 'ascii');
    disk.writeUInt16LE(512, 11);
    disk[13] = 1;
    disk.writeUInt16LE(1, 14);
    disk[16] = 2;
    disk.writeUInt16LE(224, 17);
    disk.writeUInt16LE(2880, 19);
    disk[21] = 0xf0;
    disk.writeUInt16LE(9, 22);
    disk.writeUInt16LE(18, 24);
    disk.writeUInt16LE(2, 26);
    disk[38] = 0x29;
    disk.writeUInt32LE(0x4b52595a, 39);
    disk.write('KRYZ GAME  ', 43, 'ascii');
    disk.write('FAT12   ', 54, 'ascii');
    disk[510] = 0x55;
    disk[511] = 0xaa;
    const fat = disk.subarray(512, 5120);
    fat.set([0xf0, 0xff, 0xff]);
    let next = 2;
    const offset = cluster => (33 + cluster - 2) * 512;
    function setFat(cluster, value) {
        const i = Math.floor(cluster * 1.5);
        if (cluster & 1) {
            fat[i] = (fat[i] & 15) | ((value & 15) << 4);
            fat[i + 1] = value >> 4;
        } else {
            fat[i] = value & 255;
            fat[i + 1] = (fat[i + 1] & 240) | (value >> 8);
        }
    }
    function allocate(data) {
        const count = Math.max(1, Math.ceil(data.length / 512));
        if (next + count > 2849) throw new Error('Game files exceed floppy capacity');
        const first = next;
        for (let i = 0; i < count; i++, next++) setFat(next, i === count - 1 ? 0xfff : next + 1);
        data.copy(disk, offset(first));
        return first;
    }
    function entry(position, name, cluster, size, directory = false) {
        disk.write(name.padEnd(11), position, 11, 'ascii');
        disk[position + 11] = directory ? 0x10 : 0x20;
        disk.writeUInt16LE(0x5821, position + 24);
        disk.writeUInt16LE(cluster, position + 26);
        disk.writeUInt32LE(size, position + 28);
    }
    const root = 19 * 512;
    const language = allocate(Buffer.alloc(512));
    entry(root, 'LANGUAGE', language, 0, true);
    entry(offset(language), '.', language, 0, true);
    entry(offset(language) + 32, '..', 0, 0, true);
    entry(offset(language) + 64, 'EN      CSV', allocate(english), english.length);
    if (lithuanian) entry(offset(language) + 96, 'LT      CSV', allocate(lithuanian), lithuanian.length);
    if (asciiLithuanian) entry(offset(language) + 128, 'LT      TXT', allocate(asciiLithuanian), asciiLithuanian.length);
    const run = Buffer.from('@echo off\r\nsetlocal\r\ncd /d A:\\\r\nmode con cols=125 lines=300\r\nset "game_language=en"\r\nif /I "%~1"=="lt" set "game_language=lt"\r\nif not exist A:\\ansicon.exe goto plain\r\nA:\\ansicon.exe -p\r\nif not defined ANSICON goto plain\r\ncall A:\\kryz.bat /ASCII /COLOR /L %game_language%\r\ngoto end\r\n:plain\r\ncall A:\\kryz.bat /ASCII /MONO /L %game_language%\r\n:end\r\n', 'ascii');
    for (const [i, name, data] of [[1, 'KRYZ    BAT', game], [2, 'RUN     BAT', run], [3, 'LICENSE TXT', license]]) {
        entry(root + i * 32, name, allocate(data), data.length);
    }
    entry(root + 128, 'KRYZ GAME  ', 0, 0);
    disk[root + 128 + 11] = 0x08; // volume label matches the boot sector
    if (ansi) {
        for (const [i, name, data] of [[5, 'ANSICON EXE', ansi.exe], [6, 'ANSI32  DLL', ansi.dll], [7, 'ANSI    TXT', ansi.license]]) {
            entry(root + i * 32, name, allocate(data), data.length);
        }
    }
    fat.copy(disk, 5120);
    return disk;
}
