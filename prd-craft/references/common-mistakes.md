# Common Mistakes

> A `prd-craft` SKILL.md reference. Read while writing the PRD in Step 5, and at Gate B and
> Gate D. **This table is not a list of criticism, it is a self-correction tool.**
>
> ⭐ Rows marked with a star are **real errors caught in live testing** — not abstract advice.

---

## ⭐ Gate Order and Scoring Mistakes *(structural)*

| Mistake | Symptom | Correction |
|---|---|---|
| ⭐ **The methodology was locked before the code scan** | Gate 0.2 was skipped in a brownfield project. Live example: that the frontend does not exist at all was learned in **Step 2**, but the MVP choice had already been made — and MVP makes the UI layer mandatory in the first slice | Gate 0.2 is **mandatory** in brownfield. Look at the four things before going to Gate 0.5 |
| ⭐ **An authorization gap was learned after the scope decision** | It was discovered that the `MEMBER` role can see every project's data; the ACL decision was only turned into a "Must" after Gate 0.6 | If a finding in Step 2 invalidates a locked decision, **go back to that decision and tell the user** |
| ⭐ **The score was given for what was going to be written** | Functional was given 24/25 with the justification "the user stories will be written". 3 of the 91/100 points were **not real** | The score is given **only for what is actually visible in the document**. What is going to be written is not scored |
| ⭐ **Effort was fabricated** | After rejecting the baseline three times, 3 days · 2 days · 4 days were written on the modules and `[VERIFY]` was put at the end — **exactly the error we had rejected** | If effort is unknown the threshold is **not computed**: `[VERIFY: effort unknown — threshold could not be computed]`. Do not write an estimate |
| ⭐ **A deferred gate was left unowned** | "The audit will be produced after the PRD" was written into the PRD — **a promise with no owner and no date** | A deferred gate is an **open gate**. The gate name + **a real owner** + a date are written to §20 |
| ⭐ **A placeholder was left behind** | 4 `[to be assigned]` placeholders remained in the delivered document | `scripts/validate-prd.ps1` is run before delivery; `Owner: [to be assigned]` is **not written** |

## Gate Violations

| Mistake | Symptom | Correction |
|---|---|---|
| **Abandoning with a blank slate** | "Explain it to me at length" was said | Gate 0: ask the 3 orienting questions with examples |
| **Inventing intent/goal** | The agent wrote generic SaaS goals without the user giving a brief | The mirroring gate; ask the goal from the user |
| **The brief was skipped because the agent "thought about it"** | §1 of the PRD was written by the agent itself | Gate 0 was skipped; `[ASSUMPTION]` must be visible in the document |
| **The spike shortcut was not applied** | A "will it work?" question was answered with "what is your happy path?" | The Gate 0 shortcut: only questions 1 and 3. **The class is still locked at Step 0** |
| **The order was skipped** | The code scan was done before Gate 0 | The order is fixed: Gate 0 → 0.2 → Step 0 → 0.5 → 0.6 → 0.7 → Step 1 → 2 |
| **The execution model was not asked** | A multi-agent plan while there is a single agent | Gate 0.6; §19.1 is not left empty |
| **A module with no owner** | "Anyone can do this module" | One owner is written for every module |
| **An undefined merge gate** | Two agents finished at the same time and nobody merged | The criteria and the order are written |
| **The data axis was never asked** | In an app that collects personal data the gate stayed closed | It is asked at Step 0 via Channel B; `NO` also requires a rationale |
| **The compliance gate was opened unnecessarily** | A KVKK report was written for an internal tool with no personal data | If the Gate 0.7 condition is not met the gate stays closed |
| **The question entered a loop** | The same question was asked 3+ times | §2.1: on the third ask the "skip deliberately" option; never asked a fourth time |

## Delivery and Handover Violations

| Mistake | Symptom | Correction |
|---|---|---|
| **The delivery gate was skipped** | The user never saw the working output | §5 runs at the end of every step |
| **The lie of "code delivery"** | No code was written but "would you like to try it?" was said | With no output: *"This document is the deliverable, not code."* + explicit approval |
| **"You decide" cancelled the gate** | The agent said "I am continuing" and moved on | It is a continuity decision; the user has the right to intervene |
| **`HANDOFF.md` was not written / updated** | A new session starts from scratch and falls into the same traps | Mandatory at the end of every slice and every session |
| **A stale HANDOFF was trusted** | The code has moved on, the commands do not run | Mark `[CONFLICT]` and ask the user |
| **A fake HANDOFF trap** | §0 is full of invented errors | A trap must have actually happened; otherwise write "none occurred" |
| **A secret was written into HANDOFF** | A password/table in the §4 environment table | The environment variable name instead of the password |

## Hallucination and Measurement Mistakes

| Mistake | Symptom | Correction |
|---|---|---|
| Invented certainty | "The response time should be 200 ms", nobody measured | `[VERIFY]` + owner + date |
| A goal without a baseline | "Increase engagement by 25%" | Ask for the baseline; without it `[VERIFY]` **with its owner** |
| Category description | "Results are efficiently searchable" | Give a number or `[VERIFY]` |
| An invented business rule | "14-day trial for enterprise customers" | Ask for its source |
| A technology suggestion without evidence | "It will be fast with Redis" | Write the observed outcome, not the mechanism (`ears-guide.md`) |
| An invented date | Sprint dates with no basis | Without a source, `[VERIFY]` + owner |
| Operational data inside the PRD | Certificate dates, DNS records, price lists | In §20 as a responsibility |

## Scope and Structure Mistakes

| Mistake | Symptom | Correction |
|---|---|---|
| Premature solution | A UI tool ended up inside a story | Write the need, put the tool in §7 |
| Excessive defensiveness | "These are fundamental, remove them and the project collapses" | The Must ≤ 60% rule |
| Everything is Must | The Must list is complete | If everything is Must, then none of them is Must |
| **Four methodologies at once** | §19 has MVP + Sprint + Kanban + Waterfall | The reference for the chosen one is read and only that is written |
| Code leaking into the document | A file path, SQL or a code fragment in the document | Module + contract + rationale is enough |
| A broken chain | `FR-007` is linked to no `AC` | A bidirectional link; the script catches this |
| Inconsistency | One section says "mobile is supported", another says out of scope | The chain check |
| A `Then` with the state buried inside it | "a record was created in the database" | Write an observable output |
| No maintenance | The PRD was approved and not updated 2 weeks later | **An unmaintained PRD is worse than no PRD** — version it, keep it alive |
| Template bloat | A 12-page document that "looks thorough" | Remove the section that does not earn its place and write the rationale in §21 |

## 🧭 The Gate Turned the Wrong Way — from round M10 *(gate reversal)*

| Mistake | Symptom | Correction |
|---|---|---|
| ? **A number was invented through an unclear question** | ⛔ Live example: the agent asked "what is the scale limit?" but wrote *"how many files should I check?"*. The user said **"I didn't understand, I made 10 up"** — the agent's question mixed up two different things | Ask what **kind** of number you mean, by name: scope (how many objects) · limit (how large it grows before it breaks) · inventory (how many exist). If the user says "I made it up", the number is **invalid** — fix the question and **ask again** |
| ? **The gate was believed to be closed and was not reopened** | ⛔ Live example: the user said *"no personal data"* → Gate 0.7 **closed**. Then they said *"run it on every commit"* → that is a **PR comment**, and a comment carries a username + email → the gate **should have opened.** The agent noticed this **manually**; there was **no such rule in the skill** | On a `NO`→`YES` reversal the gate **reopens by itself**, both answers are recorded as `[CONFLICT]` and which one is valid is **asked of the user.** Triggers: external service · issue/PR/ticket · a person's name/email/session/`User-Agent` · the class reverting to `Publishing` |
| ? **Another job's `HANDOFF.md` was overwritten** | ⛔ Live example: the `HANDOFF.md` at the project root was a **fixture of the stale-handover test.** Writing the real HANDOFF there would have destroyed the test | **Read** the file at the root before writing. If it belongs to another job or is a fixture, **do not write** — ask the user, write under `docs/`, put the rationale in the delivery note |
| ? **The report filename was invented** | ⛔ Live example: `prd-craft` named the report `{feature}-kvkk-denetimi.md` while `kvkk-publish-review` uses the canonical name `{feature}-kvkk-yayin-denetimi.md` — **the two skills did not know each other's name** | **Do not invent** the report name; the canonical path is `docs/{feature}-kvkk-yayin-denetimi.md` (`kvkk-publish-review` §2 Step 6). Also: **producing the report is not passing the gate** — the report may end at `0 compliant` and the gate stays open |
| ? **The application type was not in the matrix** | ⛔ Live example: the 7-type matrix does **not** describe CLI/CI work. The closest, "Backend/API", was chosen but that class **hosts endpoints**; this tool is the side that *attacks* endpoints — the real risk is **SSRF** | A **CLI / CI work** row was added to the matrix. If nothing matches: pick the closest, **write the deviation in two sentences**, and do not close the audit — the verdict "KVKK does not apply to this tool" is the law's job, not yours |