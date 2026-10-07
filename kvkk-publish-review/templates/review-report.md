# KVKK / Publishing Audit Report Template

> This is the Step 4 output of the `kvkk-publish-review` skill. It is written to
> `docs/{feature}-kvkk-yayin-denetimi.md` and linked from §20 of the PRD by file path.
> **None of the four subsections may be left empty.**

---

# KVKK / Publishing Audit Report — [Project / Feature Name]

**Audit date:** [YYYY-MM-DD]
**Scope:** [commit hash / branch / release address]
**Application type:** [one of the 7 types — the matrix in `references/kvkk-compliance-audit.md` §1]
**Triggering gate:** [Data axis `YES` or class `Publishing`, or both]
**Audited by:** [name / agent]

---

## 1. Status Legend

**A status has four values:** `Compliant` · `Gap` · `Conflict` · `To be verified`

> **Without evidence, `Compliant` is not written.** Everywhere you are unsure, write
> `To be verified`. Because this section grants publication permission, a "Compliant" written on
> a material matter creates legal risk.

---

## 2. Audit Table

| # | Item | File:line | Status | What to do | Owner | Date |
|---|---|---|---|---|---|---|
| KV-01 | [data collection point] | [file:line] | Compliant | — | | |
| KV-01 | [data collection point] | [file:line] | Gap | | | |
| KV-02 | [external service] | [file:line] | Conflict | | | |
| KV-03 | [text ↔ site difference] | [page ↔ file:line] | Conflict | | | |
| KV-04 | [consent checkbox] | [file:line] | Gap | | | |
| KV-05 | [the request that a rejection blocks] | [file:line] | To be verified | | | |
| KV-06 | [security finding] | [file:line] | Conflict | | | |

> **`File:line` is the exception here in the PRD body.** The PRD body goes stale over time,
> which is why no file path or line number is written in it. **An audit report is a snapshot of
> a moment** and must be traceable; that is why the line number is written. The date and scope
> note at the top of the report manages this "it may go stale" risk.

**No `To be verified` row may remain in this table.** For every remaining `To be verified` row,
an item is written in section 4 below and it is marked as a **blocking open question** in the
PRD.

---

## 3. Data Inventory

| Data | Collecting point | Where it goes | Legal basis | Retention | Transfer (cross-border?) |
|---|---|---|---|---|---|
| [name, email] | [form / screen] | [table / email service / API] | [contract art. 5/1 · explicit consent] | [duration] | [service — country] |

**This table is not left empty.** If it is "no personal data is collected", that sentence is
written **on a single line** and its rationale is given: *which screens, which endpoints and
which panel were scanned.*

---

## 4. Not Verifiable From Code

**This subsection is not left empty.** Every item that cannot be verified from code is written
here, together with the browser or panel step.

| Item | Why it cannot be verified from code | How to check it | Owner | Date |
|---|---|---|---|---|
| | | [Network panel · Application/Cookies · provider panel · `curl -I`] | | |

**An unchecked item is never written as if it were checked.**

---

## 5. Summary — Is It Ready to Publish?

| Gate | Status | Note |
|---|---|---|
| KVKK Tier A (legal) | | |
| KVKK Tier A-2 (deep audit) | | |
| Publishing Tier B (infrastructure) | | |
| `To be verified` items remaining | | |
| **Outcome** | ⛔ Not ready to publish / ✅ Ready to publish | Rationale |

---

## 6. Closing — Mandatory, Verbatim

> This review does not replace legal advice; the legal texts must be approved by the company
> itself, together with a lawyer where necessary.