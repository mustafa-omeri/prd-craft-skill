# ROUTING.md — Which Skill Answers Which Request

> This file is the **single routing point.** Before answering a request the agent looks here,
> makes its decision and **declares** it. The bodies of the SKILL.md files cannot **manage** this
> decision — a body that is never entered is never read. The decision is made here.

---

## 1. Mandatory Decision Declaration

For every request, the very first line of the answer is written in this form:

```
skill: <prd-craft | kvkk-publish-review | none | undecided> · rationale: <one sentence>
```

| Rule | Why |
|---|---|
| `none` is a **valid** answer | Not every request enters a skill. Writing `none` **with a rationale** is itself **compliance** |
| The declaration is the **first line of the request** | Appended at the end it goes unchecked; at the start it cannot be missed |
| The rationale is **one sentence**, the request is not repeated | If "can you do this for me" is repeated, the declaration gets lost |
| The declaration **reflects reality** | Something that is not done is not written; something not written is not counted as done |

> ⛔ **The declaration does not replace the decision.** Writing `skill: prd-craft` and then
> skipping Gate 0 invalidates the declaration. The declaration is the **entry**; the behaviour
> itself is separately subject to audit.

---

## 2. Routing Table

| Request class | Decision | Rationale |
|---|---|---|
| New feature · new project · scope clarification | `prd-craft` | Producing the document is this skill's job |
| Requirements document · user story · acceptance criteria · test scenario | `prd-craft` | The §13/§14 chain is built here |
| Delivery plan · methodology choice · execution model | `prd-craft` | Gate 0.5 / Gate 0.6 |
| Session handover · `HANDOFF.md` | `prd-craft` | §6 |
| **Personal data declaration `YES`** (form · membership · newsletter · payment · analytics · session log · chat) | `kvkk-publish-review` | ⛔ The KVKK audit is **bound to this declaration** |
| Public web (`landing page` · corporate site · portfolio · documentation site) | `kvkk-publish-review` | The publishing checklist is mandatory in this class |
| Query · index · schema · column selection | `prd-craft` | ⛔ It is a database decision; it falls under Gate D's **writing boundary** |
| **Behaviour audit of an existing tool** (code is read, "is this tool safe / KVKK compliant / which type" ) | `kvkk-publish-review` | ⛔ **Code exists but has not been examined** — type detection + KV-01..KV-06 belong to this class |
| Writing the **result** of an audit · locating the report file | `kvkk-publish-review` | The canonical report name and the §20 link are this skill's rules |
| Single-line code fix · formatting only · pure code review | `none` | Done directly |
| Re-reading / summarising an already written document | `none` | Not rewritten, summarised |
| Writing code · general architecture advice | `none` | These two skills do not write code |

---

## 2b. ⛔ When No Line Matches, `none` IS NOT the Answer

⛔ This table **does not leave anything out of scope.** For a request that fits no line:

| Situation | Correct answer |
|---|---|
| It sits on a line in the table | The decision on that line |
| **It sits on no line at all** | `skill: undecided · rationale: <which line it failed to match>` — **enter the skill**, ask for the rationale |
| Deliberately outside both of these skills | `skill: none · rationale: <why neither of these two skills fits>` |

> ⛔ **Live measurement:** in the `behavior-cli-type-ssrf` run the agent did not match the table
> for "behaviour audit of an existing tool", said `skill: none` and **wrote its own audit note
> outside the skill.** The content was correct (SSRF, RFC1918, redirect hops) but **the type
> detection and the rationale for the deviation were missing.** ⛔ Cause: that line was **not in
> the table.**
>
> ⛔ **Consequence:** producing `none` for an unmatched request silences the system as "out of
> scope" and pushes the agent to **invent its own rule.** That is why `none` may only be used
> **with a rationale** and alongside the **`undecided`** option.

---

## 3. ⛔ KVKK Does Not Apply to Every Project

`kvkk-publish-review` **does not engage on its own.** One of two gates must open:

| Gate | Condition | Outcome |
|---|---|---|
| **Personal data declaration** | Data axis `YES` — personal data is collected / stored / processed | The KVKK audit is **mandatory** |
| **Publishing class** | Public web | The publishing checklist is **mandatory** (KVKK may be answered `NO` with a written rationale) |
| Neither | — | ⛔ This skill **does not run**, the rationale is written to the PRD |

> ⛔ **Without a data-axis declaration the KVKK audit does not start.** Saying "there is no data"
> is an observation; the declaration is taken **from the user** and recorded with its rationale.
> Otherwise an audit applied to every project becomes an audit applied to none.

> ⛔ **The Publishing class is not exempt from KVKK.** An exemption is only granted **with a
> written rationale.**

---

## 4. Ordering Rule

If a request matches several lines, **the narrower one wins:**

```
index question + "write this report too"  →  prd-craft  (the document's scope first)
KVKK question + index question            →  kvkk-publish-review  (the personal data declaration first)
neither                                   →  none + rationale
```

> ⛔ **The routing decision is never made in a SKILL.md body.** A body is only read after it has
> been entered. The decision is made here; the body **applies** it.