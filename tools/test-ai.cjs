// Exercise the actual batch AI subroutines under cmd.exe.
const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');
const assert = require('node:assert/strict');
const root = path.join(__dirname, '..');
const source = fs.readFileSync(path.join(root, 'kryz.bat'), 'utf8').replace(/\r\n/g, '\n');
const routines = source.slice(source.indexOf('\n:kompiuteris\n') + 1, source.indexOf('\n:laimejimas\n'));
const lines = ['012', '345', '678', '036', '147', '258', '048', '246'];
const order = [4, 0, 2, 6, 8, 1, 3, 5, 7];
const put = (board, i, mark) => board.slice(0, i) + mark + board.slice(i + 1);
const won = (board, mark) => lines.some(line => [...line].every(i => board[i] === mark));
function threats(board, mark) {
  return [...new Set(lines.flatMap(line => {
    const cells = [...line];
    return cells.filter(i => board[i] === mark).length === 2
      ? cells.filter(i => board[i] === '.').map(Number) : [];
  }))];
}
function strategy(board) {
  for (const mark of ['O', 'X']) {
    const moves = threats(board, mark);
    if (moves.length) return moves.at(-1);
  }
  return order.find(i => board[i] === '.' && order.every(j => {
    const candidate = put(board, i, 'O');
    if (candidate[j] !== '.') return true;
    const reply = put(candidate, j, 'X');
    return threats(reply, 'O').length > 0 || threats(reply, 'X').length < 2;
  }));
}
const positions = new Map();
function explore(board = '.........') {
  if (won(board, 'X') || won(board, 'O') || !board.includes('.')) return;
  for (const i of order) if (board[i] === '.') {
    const next = put(board, i, 'X');
    if (won(next, 'X') || !next.includes('.')) continue;
    const move = strategy(next);
    assert.notEqual(move, undefined, next);
    positions.set(next, move + 1);
    explore(put(next, move, 'O'));
  }
}
explore();
const harness = path.join(root, '.ai-test.bat');
const gameHarness = path.join(root, '.ai-game.bat');
function move(board, difficulty) {
  const setup = [...board].map((cell, i) => `set "e${i + 1}=${cell}"`).join('\r\n');
  fs.writeFileSync(harness, `@echo off\r\nsetlocal DisableDelayedExpansion\r\n${setup}\r\nset zaidejas2=O\r\nset difficulty=${difficulty}\r\ngoto kompiuteris\r\n${routines.replace(/\n/g, "\r\n")}\r\n:tikrink\r\necho MOVE=%ejimas%\r\nexit /b\r\n:pabaiga\r\nexit /b 1\r\n`);
  const result = spawnSync('cmd.exe', ['/d', '/c', harness], { cwd: root, encoding: 'utf8', timeout: 10000 });
  assert.equal(result.status, 0, result.stderr || result.error?.message);
  const chosen = Number(result.stdout.match(/MOVE=(\d)/)?.[1]);
  assert.equal(board[chosen - 1], '.', `Illegal ${difficulty} move on ${board}: ${result.stdout}`);
  return chosen;
}
try {
  assert.equal(move('OO.XX.X..', 'normal'), 3, 'Take a win before blocking');
  assert.equal(move('XX..O....', 'normal'), 3, 'Block an immediate win');
  assert.equal(move('X...O...X', 'hard') % 2, 0, 'Prevent opposite-corner forks');
  // Run the actual batch decision for every position reachable against Hard.
  const cases = [...positions].map(([board]) => [...board].map((cell, i) => `set e${i + 1}=${cell}`).join('\n') + `\ncall :hard_move\necho ${board}=%ejimas%`).join('\n');
  fs.writeFileSync(harness, (`@echo off\nsetlocal DisableDelayedExpansion\n${cases}\nexit /b\n${routines}\n`).replace(/\n/g, '\r\n'));
  const result = spawnSync('cmd.exe', ['/d', '/c', harness], { cwd: root, encoding: 'utf8', timeout: 120000 });
  assert.equal(result.status, 0, result.stderr || result.error?.message);
  assert.equal(result.stderr, '');
  const actual = new Map(result.stdout.trim().split(/\r?\n/).map(row => row.split('=')));
  assert.equal(actual.size, positions.size);
  for (const [board, expected] of positions) assert.equal(Number(actual.get(board)), expected, board);
  let games = 0;
  function play(board = '.........') {
    assert.ok(!won(board, 'X'), `Hard lost: ${board}`);
    if (won(board, 'O') || !board.includes('.')) { games++; return; }
    for (const i of order) if (board[i] === '.') {
      let next = put(board, i, 'X');
      if (!won(next, 'X') && next.includes('.')) {
        const move = Number(actual.get(next)) - 1;
        assert.equal(next[move], '.', next);
        next = put(next, move, 'O');
      }
      play(next);
    }
  }
  play();
  console.log(`Actual batch Hard verified: ${actual.size} positions and ${games} games without a loss.`);
  const table = [...positions].map(([board, move]) => `${board}=${move}`);
  for (let i = 0; i < table.length; i += 101) {
    const [board, expected] = table[i].split('=');
    assert.equal(move(board, 'hard'), Number(expected));
    move(board, 'easy');
    move(board, 'normal');
  }
  // Drive a complete game, replay it, and quit through the real entry point.
  const lookup = new Map(table.map(row => row.split('=')));
  const wins = ['012', '345', '678', '036', '147', '258', '048', '246'];
  let board = '.........';
  const inputs = [];
  const place = (i, mark) => { board = board.slice(0, i) + mark + board.slice(i + 1); };
  const finished = () => !board.includes('.') || wins.some(line => ['X', 'O'].some(mark => [...line].every(i => board[i] === mark)));
  while (!finished()) {
    const i = board.indexOf('.');
    inputs.push(String(i + 1));
    place(i, 'X');
    if (!finished()) place(Number(lookup.get(board)) - 1, 'O');
  }
  for (const [args, prefix, yes, no, label] of [
    ['/D hard', [], 'yes', 'no', 'Difficulty: Hard'],
    ['', ['3'], 'yes', 'no', 'Difficulty: Hard'],
    ['/L lt /D hard', [], 'taip', 'ne', 'Sunkumas: Sunkus'],
  ]) {
    const queue = [...prefix, ...inputs, yes, ...inputs, no];
    const setup = queue.map((value, i) => `set "input${i + 1}=${value}"`).join('\r\n');
    // Inject queued responses: cmd's UTF-8 redirected SET /P is unreliable in CI.
    const game = source.replace(/^set \/p "(ejimas|ats|difficulty_choice)=.*$/gim, 'call :test_read $1');
    fs.writeFileSync(gameHarness, (`@echo off\nset input_index=0\n${setup}\n${game}\n:test_read\nset /a input_index+=1\ncall set "%1=%%input%input_index%%%"\nexit /b\n`).replace(/\r?\n/g, '\r\n'));
    const result = spawnSync('cmd.exe', ['/d', '/c', `.ai-game.bat /MONO ${args}`], {
      cwd: root, encoding: 'utf8', timeout: 10000, maxBuffer: 1024 * 1024,
    });
    assert.equal(result.status, 0, result.stderr || result.error?.message);
    assert.ok(result.stdout.includes(label), result.stdout);
    assert.ok(!result.stderr, result.stderr);
  }
  console.log('Batch AI verified: wins, blocks, fork defense, and legal moves across all levels.');
} finally {
  fs.rmSync(harness, { force: true });
  fs.rmSync(gameHarness, { force: true });
}
