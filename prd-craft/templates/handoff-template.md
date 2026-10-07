# HANDOFF Template — A New Session Starts Here

> This file lives at the project root under the name `HANDOFF.md`. **One location, one file** —
> it is not searched for, no copies are kept. Writing rules: `prd-craft` SKILL.md §6.

---

# HANDOFF — A New Session Starts Here

> This file exists for a single purpose: **a new session should know what this session did,
> should not fall into the same mistakes, and should continue from where it stopped.**
>
> Current: **[YYYY-MM-DD]** · Agent: **[Agent Name]**
> Related PRD: `docs/[feature]-prd.md` · Decision records: `knowledge-base.md`

---

## 0. ⛔ READ THIS FIRST — Traps Hit and Proven in This Session

| # | Rule & Trap | Concrete Cause / What Happened | Correct Path |
|---|---|---|---|
| 1 | | | |

> **This table cannot be invented.** Every row records a concrete mistake **actually
> encountered and solved** during the session (wrong port, glob error, wrong role, a test that
> passes falsely, conflicting branches…).
>
> **If this session has no traps yet**, write this in the table and do not delete it:
> `| — | No verified trap occurred in this session. Do not add one before actually hitting it. | — | — |`

---

## 1. What Was Done This Session (Summary)

- **Backend:** [changes made, test results]
- **Frontend:** [UI changes, i18n additions]
- **Documentation:** [documents updated, PRD version]
- **Tests:** [how many tests written / how many passed / how many were not run and why]

---

## 2. ⚠️ HEALTH STATUS — Points Needing Attention

- [Fragile areas, risk of tests passing falsely, tests that were not run, temporary
  solutions ("TODO", "for now")]

> ⛔ **Disabling tests is not a solution, it is a deferral.** Every deferral written here is a
> real debt the next session inherits.

---

## 3. ⏭️ CONTINUE FROM HERE — Ordered Work

### Status legend

| Mark | Meaning |
|---|---|
| ⏳ | Next, not started yet |
| 🔄 | Being worked on |
| ✅ | Done and verified |
| ⛔ | Blocked — the reason and the person who can unblock it are written down |

### Verify First (2 Commands To Run Immediately)

```bash
# 1. Build / type check
[command]

# 2. Tests
[command]
```

> These are commands **that were actually run.** No estimated commands are written. If the
> project has no such command it is marked `[VERIFY]` and the user is asked.

### Next Tasks

| # | Status | Task | Depends on | Note |
|---|---|---|---|---|
| 1 | ⏳ | | — | |
| 2 | ⏳ | | 1 | |
| 3 | 🔄 | | — | |

### When this file is updated

It is updated **immediately** when **any one** of the following happens — do not wait for the end
of the session:

- [ ] A task went ⏳ → 🔄 → ✅
- [ ] A slice / step finished (if the Delivery Gate ran, a note is added here too)
- [ ] A trap occurred and was solved (written to §0)
- [ ] The user ended the session / opened a new one

---

## 4. Environment Information & Verified Test Accounts

| Parameter | Value | Note |
|---|---|---|
| Backend port | | |
| Frontend port | | |
| Database / port | | |
| Test accounts | [role, username] | passwords are not shared |
| Run command | | |
| Git rule | ⛔ Commit / push / tag without approval **MUST NOT HAPPEN** | |

> **No secret is written in this table.** Password, token, key → write the environment variable
> name, not its value.

---

## 5. Domain Model & Critical Contracts

- [The model relationships that are most often misunderstood]
- [Deletion standard (soft delete or hard delete)]
- [Mutation rule (POST, or PUT/DELETE)]
- [If there are multiple agents: the interface expectations of the other agents, who owns the contract]

---

## 6. How a Decision Reaches This File

⛔ **Read the file at the root before writing — it is not always this skill's.**

| Situation | What to do |
|---|---|
| `HANDOFF.md` **does not exist** | Copy the template from this file, write the "no traps yet" note in `§0`, fill `§3` from the real situation in the project |
| `HANDOFF.md` **exists but is empty / still a template** | Fill in the work done and the continuing tasks; if `§0` stays empty write the note above |
| `HANDOFF.md` **is filled** | Read all the tables, use the `§0` traps as context, continue according to the status marks in `§3` |
| `HANDOFF.md` **is stale** (old date, code has moved on) | Compare against the code; **do not trust the file blindly.** Mark contradicting lines `[CONFLICT]` and ask the user |
| ⛔ `HANDOFF.md` **is a test fixture or belongs to another job** | ⛔ **Do not write over it** — ask the user. Write under `docs/` temporarily, put the rationale in the delivery note. Do not delete this file, **it is part of a fixture test** |