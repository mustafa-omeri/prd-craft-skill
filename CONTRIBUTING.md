# Contributing

## Before you open a pull request

Run all three. A pull request that skips them will be asked for them.

```powershell
pwsh      -File ./validate.ps1           # structure: expect 133 PASS / 0 KALDI
powershell -File ./validate.ps1          # must be identical to the pwsh result
node ./evals/run-evals.mjs --selftest    # L0_SUMMARY passed=26 failed=0
```

### Why run `validate.ps1` twice

`powershell` (Windows PowerShell 5.1) and `pwsh` (PowerShell 7+) default to different
encodings. A file without a UTF-8 BOM is read as ANSI by 5.1, which silently breaks Turkish and
other non-ASCII comparisons. If the two engines disagree, the file has an encoding bug — not a
logic bug.

Rule of thumb: **keep the BOM, and give every `Get-Content` an explicit `-Encoding UTF8`.**

### What green actually means

`validate.ps1` measures **structure**, not correctness. Green means *"the rules are consistent
with each other"*. It does **not** mean *"the rules are right"*.

Only the L1 eval measures behaviour, and only a human can score it. See below.

---

## Rules for changing this repository

### 1. Every new check must be proven to fail

A check that has never gone red has never been tested. Before you claim a check works, break
the file it inspects and confirm it reports `KALDI`.

```powershell
# example: prove the "undecided fallback" check is alive
# temporarily delete the word from ROUTING.md, run validate.ps1, expect KALDI, then restore
```

Prefer a specific anchor over a single common word. A check that greps for `audit` in a file
that happens to contain the word `audit` eight times passes no matter what you delete.

### 2. Keep `ROUTING.md` as the single routing point

The body of a `SKILL.md` cannot manage whether the skill is entered — a body that is never
entered is never read. Any rule about *whether to engage* belongs in `ROUTING.md`, and both
skills must carry a decision declaration pointing at it.

### 3. Keep SKILL.md at or under 500 lines

The limit exists so the file fits an agent's context budget. Use progressive disclosure: detail
belongs in `references/`, and `SKILL.md` links to it. References are **one level deep only**.

If English no longer fits, compress the prose — do not raise the limit.

### 4. One derived fact, one source

If a number appears in two places, one of them will go stale. Counts like the application-type
matrix size are checked against their source by `validate.ps1`; keep it that way.

### 5. Update the recorded numbers

`validate.ps1` prints its check count, and the README quotes it. If you add or remove a check,
update both. A record that disagrees with the code makes the next contributor think the command
is broken.

---

## Changing an eval case

`evals/evals.json` is the behavioural suite. The runner enforces several rules on it:

- a **negative** case must carry an explicit *not-engage* rationale, not just an expectation
- a negative case's prompt must be a real request that would plausibly trigger the skill
- a **behavioural** case must have at least two expected items — one item is a weak assertion
- no `TODO` / `FIXME` / `XXX` / `TBD` inside any case

Run `node ./evals/run-evals.mjs --selftest` after editing.

### Scoring L1

```
node ./evals/run-evals.mjs                 # interactive, y/n per item
node ./evals/run-evals.mjs --grader separate
```

- `--brief` asks one decision per case. **It is not evidence** — answering "pass" 23 times in
  a row is fatigue, not verification.
- **A human must give the grade.** An agent writing its own grade makes the run worthless.
- `--grader same` means the grading agent also performed the behaviour: that is not evidence.
  `--grader separate` is stronger, though the sub-agents still read the same `SKILL.md`.
- The runner **cannot verify** that the separation is real; it only records your declaration.
- Any case left ungraded counts as `NOT RUN`, which blocks a green result on purpose.

---

## Adding a reference file

1. Put it under the relevant skill's `references/`.
2. Link it from `SKILL.md` §9 with **when to read it**. An unlinked reference is never read.
3. `validate.ps1` §4 verifies that every referenced file exists — a broken path fails.
4. References are **one level deep**. Do not create `references/sub/other.md`.

---

## Style

- The repository is **English only**. Non-English prose in a shipped file fails the CJK/encoding
  checks and is a bug, not a style choice.
- `validate-prd.ps1` is deliberately **ASCII-only**: non-ASCII string literals in a `.ps1` can be
  mangled while the file is read and silently break the matches.
- Prefer a specific literal over a loose regex. Prove it by mutation.

## Legal scope

`kvkk-publish-review` encodes Turkish law. It does not apply that law to projects with no Turkish
nexus: the jurisdiction is **asked** and the gate closes when the answer says otherwise.

⛔ **Never add GDPR article numbers from memory.** The EU track is deferred and
[`ROADMAP.md`](ROADMAP.md) says why — inventing citations would be the exact failure this skill
exists to prevent. If you add another jurisdiction, put it in a **new reference file** and say
which one applies.

## Two gates you must not break

Both are validated, and both have mutation tests:

- **Language gate.** The user is asked once which language the document is written in. `SKILL.md`
  stays English because the *agent* reads it; the *questions* and the *output* follow the user's
  choice. Do not translate the skill files.
- **Jurisdiction gate.** Never inferred from the language the user writes in, from their name, or
  from where the code is hosted. The right to decline is absolute.