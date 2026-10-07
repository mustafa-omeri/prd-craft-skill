# prd-craft

Two agent skills that turn a vague feature idea into a **requirements contract** an AI coding
agent can implement without asking a single further question.

| Skill | What it does |
|---|---|
| **`prd-craft`** | Guides the idea through a brief interview, classifies it, picks a delivery methodology and an execution model, then writes a PRD that passes a 100-point document gate. |
| **`kvkk-publish-review`** | Audits personal data handling and public web publishing. Turkish law (KVKK) — see the [jurisdiction warning](#jurisdiction-warning). |

They are **platform independent**. Any agent that can read a folder containing a `SKILL.md` can
use them — Claude Code, Cursor, opencode, Codex, Gemini CLI, or your own harness.

---

## Install

### From a clone

```bash
git clone https://github.com/<owner>/prd-craft.git
cd prd-craft

./install.sh                        # into ./.agents/skills   (this project only)
./install.sh user                   # into ~/.agents/skills   (all your projects)
./install.sh project /path/to/repo  # into another project
./install.sh --dry-run user         # print what would happen, write nothing
```

```powershell
pwsh -File ./install.ps1                        # into ./.agents/skills
pwsh -File ./install.ps1 -Target user           # into ~/.agents/skills
pwsh -File ./install.ps1 -Target project -Destination C:\work\my-app
pwsh -File ./install.ps1 -Target claude         # into ./.claude/skills
pwsh -File ./install.ps1 -WhatIfOnly            # print what would happen, write nothing
```

The installer only copies files. **It never edits your agent configuration.** If your harness
uses a different directory, copy `prd-craft/`, `kvkk-publish-review/` and `ROUTING.md` into it
yourself — they are all the set needs.

> Keep `ROUTING.md` next to the two skill folders. It is the single point where the "which
> skill answers this request" decision is made.

### Manual install

```
your-project/
└── .agents/
    └── skills/
        ├── prd-craft/
        ├── kvkk-publish-review/
        └── ROUTING.md
```

Restart your agent session afterwards so it picks the skills up.

---

## Verify the install

Ask your agent something like *"I want an app that finds broken links in our documents"* and
check the **first line** of its answer:

```
skill: prd-craft · rationale: a new feature with an unclear scope belongs to Gate 0.
```

That first line is a **decision declaration**. It is mandatory on every request, and `none` and
`undecided` are both valid answers — see `ROUTING.md`.

If the agent answers without that line, the routing rules did not engage: tell it to read
`ROUTING.md` first.

---

## How it works

`prd-craft` runs a fixed sequence of gates. The order is deliberate and must not be changed.

```
Gate 0    Guided Brief         get the intent from the user, mirror it back
Gate 0.2  Pre-Scan             brownfield only: manifest, modules, tests, auth, is there a UI
Step 0    Classify + data axis   lock the class, open or close the compliance gate
Gate 0.5  Methodology           MVP / Sprint Agile / Kanban / Waterfall
Gate 0.6  Execution model       single agent or multi-agent
Gate 0.7  Compliance routing    is kvkk-publish-review in play
Gate B    BRIEF GATE            5 yes/no gates, no score, before writing
Step 5    Write the PRD         docs/{feature}-prd.md
Gate D    DOCUMENT GATE         100 points, 90 threshold, no new questions
Step 6    Delivery Gate         HANDOFF.md session bridge
```

The rules that matter most:

- **Documentation first, code after.** Nothing becomes code before its contract is clear.
- **No fabricated numbers.** Baseline, effort, dates and metrics are never guessed. Unknown
  means `[VERIFY]` + owner + date.
- **Ask what kind of number you mean.** "How many files?" is three different questions:
  **scope**, **limit**, **inventory**. If the user says they made the number up, it is invalid
  and the question is asked again.
- **A deferred gate is not a closed gate.** "We'll do the audit later" leaves the gate open
  with a named owner and a date inside the PRD.
- **The score is never inflated.** A dimension earns full marks only for something actually
  present in the document.

Full rules: [`prd-craft/SKILL.md`](prd-craft/SKILL.md).

---

## Jurisdiction warning

`kvkk-publish-review` encodes **Turkish law (KVKK, Law 6698)** and is written for **Turkey**.

Outside Turkey, use it for its *mechanics* — the data inventory, the bidirectional
notice-versus-site comparison, the evidence that consent is actually enforced, the publishing
checklist — and **replace every legal citation with your own jurisdiction's rules.**

---

## Repository layout

```
prd-craft/
  SKILL.md                     the 500-line contract the agent reads
  references/                  9 progressive-disclosure references
  templates/                   PRD, HANDOFF and quality checklist templates
  scripts/validate-prd.ps1     machine check run before a PRD is delivered
  evals/evals.json             behavioural test cases
kvkk-publish-review/
  SKILL.md
  references/
  templates/review-report.md
  evals/evals.json
ROUTING.md                     the single routing point for both skills
evals/run-evals.mjs            eval runner (L0 automatic + L1 interactive)
validate.ps1                   122 structural checks over the skill set
```

---

## Contributing

Run both checks before you open a pull request:

```powershell
pwsh      -File ./validate.ps1            # structure: expect 122 GECTI / 0 KALDI
powershell -File ./validate.ps1           # must be identical; a difference means an encoding bug
node ./evals/run-evals.mjs --selftest    # expect: L0_SUMMARY passed=26 failed=0
```

`validate.ps1` measures **structure**, not correctness. Green means "the rules are consistent",
**not** "the rules are right".

If you change a check, prove it can fail: break the file it inspects and confirm it reports
`KALDI`. A check that has never failed has never been tested.

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Sources

The methodology is assembled from public practice; the per-item attribution is in
[`prd-craft/references/sources.md`](prd-craft/references/sources.md), including EARS, RFC 2119,
the Gherkin contract, MoSCoW, JTBD and INVEST.

## License

[MIT](LICENSE)