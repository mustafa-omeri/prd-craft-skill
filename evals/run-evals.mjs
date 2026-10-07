#!/usr/bin/env node
// Eval runner — prd-craft / kvkk-publish-review
//
// Purpose: validate the evals/evals.json files on two layers.
//   L0 (automatic, deterministic) : file structure, id uniqueness, content patterns
//   L1 (interactive, human)       : whether the skill actually behaves correctly
//
// ⛔ L0 does NOT mean "the skill is right". L0 only means "the test definitions are
//    consistent". Without L1 the skill counts as not verified.
//
// Usage:
//   node run-evals.mjs --list       lists cases, runs L0
//   node run-evals.mjs --selftest   L0 only
//   node run-evals.mjs              L0 + L1 (asks a question per case)
//   node run-evals.mjs --noninteractive  L0 + checklist (nobody answers)
//   node run-evals.mjs --grader same|separate  DECLARES who gave the grade (not verified!)
//
// Exit code: 0 = L0 passed and L1 has no fail · 1 = there is a fail

import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createInterface } from 'node:readline';

const HERE = dirname(fileURLToPath(import.meta.url));

// This file lives in evals/; the skill folders are one level up.
const ROOT = join(HERE, '..');
const SKILLS = ['prd-craft', 'kvkk-publish-review'];

let pass = 0;
let fail = 0;
const failures = [];

const ok = (cond, label, detail = '') => {
  if (cond) { pass++; console.log(`  \x1b[32mPASS\x1b[0m    ${label}`); }
  else {
    fail++; failures.push(label);
    console.log(`  \x1b[31mFAIL\x1b[0m    ${label}`);
    if (detail) console.log(`          \x1b[90m${detail}\x1b[0m`);
  }
};

// ---------------------------------------------------------------- L0
function loadSkill(name) {
  const f = join(ROOT, name, 'evals', 'evals.json');
  if (!existsSync(f)) return { error: 'evals/evals.json is missing' };
  let j;
  try { j = JSON.parse(readFileSync(f, 'utf8')); }
  catch (e) { return { error: `invalid JSON: ${e.message}` }; }
  const cases = Array.isArray(j) ? j.flatMap(x => x.evals ?? []) : (j.evals ?? []);
  return { j, cases };
}

function l0(name) {
  console.log(`\n=== L0 · ${name} ===`);
  const { j, cases, error } = loadSkill(name);
  if (error) { ok(false, `${name}: eval file was read`, error); return { cases: [] }; }
  ok(true, `${name}: eval file is valid JSON`);

  const declared = Array.isArray(j) ? j.map(x => x.skill_name) : [j.skill_name];
  ok(declared.every(d => d === name), `${name}: skill_name matches the folder name`,
    `declared: ${declared.join(', ')}`);

  const byId = new Map();
  for (const c of cases) {
    if (!c.id) continue;
    byId.set(c.id, (byId.get(c.id) ?? 0) + 1);
  }
  ok(cases.every(c => c.id), `${name}: every case has an id`,
    (cases.filter(c => !c.id).map(c => c.type ?? c.prompt ?? '?').join(', ')));
  ok([...byId.values()].every(n => n === 1), `${name}: ids are unique`,
    [...byId].filter(([, n]) => n > 1).map(([k]) => k).join(', '));

  ok(cases.every(c => typeof c.prompt === 'string' && c.prompt.trim().length > 10),
    `${name}: every case has a meaningful prompt`);
  ok(cases.every(c => Array.isArray(c.expected_behavior) && c.expected_behavior.length > 0),
    `${name}: every case has expected_behavior filled`);

  const pos = cases.filter(c => c.type === 'positive');
  const neg = cases.filter(c => c.type === 'negative');
  const beh = cases.filter(c => c.type === 'behavioral');
  ok(pos.length >= 3, `${name}: positive triggers >= 3`, `found: ${pos.length}`);
  ok(neg.length >= 2, `${name}: negative triggers >= 2`, `found: ${neg.length}`);
  ok(beh.length >= 1, `${name}: behavioural cases >= 1`, `found: ${beh.length}`);

  // ⛔ A negative case must carry a "does not engage" rationale — writing only
  //    "expected" is not enough.
  const NOT_TRIGGER = /must not (be used|engage|apply|trigger|run)|does not (engage|apply|use|trigger)|should not (be used|engage|apply|trigger|run)|is not (used|engaged|applicable)|without engaging|not for\b/i;
  const negNoReason = neg.filter(c => !NOT_TRIGGER.test(c.expected_behavior.join(' ')));
  ok(negNoReason.length === 0, `${name}: every negative case carries a not-engage rationale`,
    negNoReason.map(c => `${c.id}: ${JSON.stringify(c.expected_behavior)}`).join(' | '));

  // ⛔ A negative case's prompt must be a real request that would trigger the skill
  const negWeak = neg.filter(c => !c.prompt || c.prompt.length < 15);
  ok(negWeak.length === 0, `${name}: negative cases contain a real request`,
    negWeak.map(c => c.id ?? '(no id)').join(', '));

  // ⛔ A behavioural case cannot be a single item — one item means a weak assertion
  const behThin = beh.filter(c => c.expected_behavior.length < 2);
  ok(behThin.length === 0, `${name}: behavioural cases have at least 2 items`,
    behThin.map(c => c.id).join(', '));

  // ⛔ placeholder / partial writing
  const dirty = cases.filter(c => /TODO|FIXME|XXX|\bTBD\b/.test(JSON.stringify(c)));
  ok(dirty.length === 0, `${name}: no placeholders inside a case`,
    dirty.map(c => c.id).join(', '));

  console.log(`  \x1b[90m(${pos.length} positive · ${neg.length} negative · ${beh.length} behavioural)\x1b[0m`);
  return { cases };
}

// ---------------------------------------------------------------- L1
const GRADES = { fail: 'FAIL', partial: 'PARTIAL', pass: 'PASS' };

// ⛔ rl.question() returns undefined once stdin closes and the runner crashes.
// Fix: stdin is read ONCE and shared across every l1 call.
// (Reconnecting each time means that once stdin is done 'end' never arrives and
//  Node exits 13 with "unfinished top-level await".)
let stdinBuf = null;
let stdinQueue = null;
async function readStdinOnce() {
  if (stdinBuf !== null) return stdinBuf;
  stdinBuf = await new Promise((res) => {
    let buf = '';
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (d) => { buf += d; });
    process.stdin.on('end', () => res(buf));
    process.stdin.on('error', () => res(buf));
  });
  // ⛔ The queue is shared too. If it is rebuilt on every l1 call, all answers
  //    are replayed from the start and the results come out quietly wrong.
  stdinQueue = stdinBuf.split(/\r?\n/).map(l => l.trim()).filter(Boolean);
  return stdinBuf;
}

async function makeReader() {
  const interactive = process.stdin.isTTY === true;
  if (!interactive) {
    await readStdinOnce();
    return async () => (stdinQueue.length ? stdinQueue.shift() : null);
  }

  const rl = createInterface({ input: process.stdin, output: process.stdout });
  const pending = [];
  rl.on('line', (l) => { const next = pending.shift(); if (next) next(l); });
  rl.on('close', () => { while (pending.length) pending.shift()(null); });
  let closed = false;
  rl.on('close', () => { closed = true; });
  return (q) => new Promise((res) => {
    process.stdout.write(q);
    if (closed) return res(null);
    pending.push(res);
  });
}

async function l1(name, cases) {
  const brief = has('--brief');
  console.log(`\n=== L1 · ${name} · ${cases.length} cases · ${brief ? 'brief (one decision per case)' : 'full (y/n per item)'} ===`);
  const askLine = await makeReader();
  const ask = async (q) => {
    const v = await askLine(q);
    return v === null ? null : String(v).trim().toUpperCase();
  };
  const tally = { pass: 0, partial: 0, fail: 0, notrun: 0 };

  for (const c of cases) {
    console.log(`\n\x1b[1m--- ${c.id}  [${c.type}]\x1b[0m`);
    console.log(`PROMPT: ${c.prompt}`);
    let yes = 0, no = 0, skip = 0;

    if (brief) {
      // Fatigue mistakes: asking 64 items and answering "yes" to everything is not
      // evidence. So one decision is taken per case first; only failing cases open up.
      console.log(`  expected: ${c.expected_behavior.length} items`);
      c.expected_behavior.forEach((b, i) => console.log(`   ${i + 1}. ${b}`));
      const v = await ask('  [g=pass / k=partial / n=no / s=skip(not run)] > ');
      if (v === 'G') { yes = c.expected_behavior.length; }
      else if (v === 'K') { yes = Math.ceil(c.expected_behavior.length / 2); }
      else if (v === 'N') { no = 1; }
      else { skip = c.expected_behavior.length; }   // 's' or EOF(null)
    } else {
      for (const b of c.expected_behavior) {
        const a = await ask(`  [y/n/?] ${b}\n> `);
        if (a === 'Y') yes++;
        else if (a === 'N') no++;
        else skip++;   // '?' or EOF(null)
      }
    }

    const verified = yes + no;
    let g;
    if (verified === 0) g = 'notrun';
    else if (no > 0) g = 'fail';
    else if (yes === c.expected_behavior.length) g = 'pass';
    else g = 'partial';

    tally[g]++;
    const col = { pass: 32, partial: 33, fail: 31, notrun: 35 }[g];
    const lbl = { pass: 'PASS', partial: 'PARTIAL', fail: 'FAIL', notrun: 'NOT RUN' }[g];
    const det = verified === 0
      ? '\x1b[35mno item was verified — this is NOT EVIDENCE\x1b[0m'
      : `${yes}/${c.expected_behavior.length} items verified${skip ? ` · ${skip} skipped` : ''}`;
    console.log(`  => ${lbl}  \x1b[${col}m${det}\x1b[0m`);
    if (g !== 'pass') console.log(`  \x1b[90mthis case must be re-examined in SKILL.md or a reference\x1b[0m`);
  }
  console.log(`\n  L1 ${name}: ${tally.pass} pass · ${tally.partial} partial · ${tally.fail} fail · \x1b[35m${tally.notrun} not run\x1b[0m`);
  return tally;
}

// ---------------------------------------------------------------- main
const argv = process.argv.slice(2);
const has = f => argv.includes(f);

console.log('\x1b[1mEval runner\x1b[0m  \x1b[90m(L0 automatic · L1 interactive)\x1b[0m');
console.log('\x1b[33m⛔ L0 does not mean "the skill is right"; it only means "the test definitions are consistent".\x1b[0m');

const loaded = {};
for (const s of SKILLS) loaded[s] = l0(s);

console.log(`\n--- L0 summary: ${pass} pass · ${fail} fail ---`);
// Machine-readable line: ASCII only. PowerShell/JSON layers parse this line;
// Turkish characters break depending on encoding, this line does not.
console.log(`L0_SUMMARY passed=${pass} failed=${fail}`);

if (has('--list')) {
  for (const s of SKILLS) {
    console.log(`\n\x1b[1m${s}\x1b[0m`);
    for (const c of loaded[s].cases ?? []) console.log(`  ${c.id.padEnd(34)} [${c.type}]`);
  }
  process.exit(fail ? 1 : 0);
}

if (has('--selftest')) {
  console.log('\x1b[90m--selftest: L1 atlandi.\x1b[0m');
console.log('\x1b[33m⛔ Skill not verified. Run the plain command for L1.\x1b[0m');
  process.exit(fail ? 1 : 0);
}

if (fail) {
  console.log('\n\x1b[31m⛔ L0 failed — while L0 is red, L1 is meaningless. Fix the definitions first.\x1b[0m');
  process.exit(1);
}

if (has('--noninteractive')) {
  console.log('\x1b[33m⛔ Non-interactive mode: L1 does not run, the skill is NOT VERIFIED.\x1b[0m');
  console.log('Answer the checklist below by hand and write the result into knowledge-base.md:\n');
  for (const s of SKILLS) {
    console.log(`\x1b[1m${s}\x1b[0m`);
    for (const c of loaded[s].cases ?? []) {
      console.log(`\n${c.id} [${c.type}]\n  PROMPT: ${c.prompt}`);
      c.expected_behavior.forEach((b, i) => console.log(`   ${i + 1}. [ ] ${b}`));
    }
  }
  process.exit(2);
}

let t = { pass: 0, partial: 0, fail: 0, notrun: 0 };
for (const s of SKILLS) {
  const r = await l1(s, loaded[s].cases ?? []);
  for (const k of Object.keys(t)) t[k] += r[k];
}

console.log('\n' + '='.repeat(60));
console.log(`  L0  ${pass} pass / ${fail} fail`);
console.log(`  L1  ${t.pass} pass / ${t.partial} partial / ${t.fail} fail / ${t.notrun} not run`);
console.log('='.repeat(60));
console.log(`L1_SUMMARY passed=${t.pass} partial=${t.partial} failed=${t.fail} notrun=${t.notrun} total=${t.pass + t.partial + t.fail + t.notrun}`);

if (t.partial > 0) {
  console.log('\x1b[33m⛔ PARTIAL RESULTS ARE NOT EVIDENCE. Shall we move on? No — fix it.\x1b[0m');
}
if (t.notrun > 0) {
  console.log(`\x1b[35m⛔ ${t.notrun} cases were NOT RUN. A case that was not run is not evidence; the skill does not count as fully verified.\x1b[0m`);
}
// ⛔ This runner CANNOT know whether the grader and the performer are the same agent.
//    An earlier version printed "it graded itself" on a single line and that was an
//    unverified claim on every run — yet the grader and the implementer CAN be
//    different when separate executor agents do the run. Instead of removing that
//    uncertainty, something measurable is put in its place.
const grader = has('--grader') ? argv[argv.indexOf('--grader') + 1] : 'unknown';
console.log(`\x1b[33m⛔ L1 grade declared as: "${grader}". The strength of the evidence depends on it:\x1b[0m`);
for (const [k, v] of Object.entries({
  'same': 'the grading agent also performed the behaviour — THIS IS NOT EVIDENCE, it only graded itself',
  'separate': 'separate agents performed the behaviour, another gave the grade — stronger, but the sub-agents read the same SKILL.md',
})) {
  console.log(`\x1b[90m   --grader ${k}  ->  ${v}\x1b[0m`);
}
console.log('\x1b[33m⛔ This runner does NOT verify that distinction itself. If it is chosen wrongly, the whole record is wrong.\x1b[0m');

// ⛔ Showing green while cases were not run would be misleading.
process.exit(fail + t.fail + t.partial + t.notrun > 0 ? 1 : 0);