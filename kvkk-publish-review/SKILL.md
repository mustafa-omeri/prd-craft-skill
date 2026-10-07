---
name: kvkk-publish-review
description: Personal data (KVKK / privacy) audit and pre-publication gate for public web releases. This skill produces a data inventory, lists external services and cross-border transfers, compares the privacy notice and cookie policy against the live site in both directions, checks whether consent checkboxes and cookie consent are actually enforced, reports security findings, and fills a 33-line publishing checklist (HTTPS, 301, soft-404, canonical, sitemap, robots, Core Web Vitals, accessibility, forms, analytics, backups). It is engaged by prd-craft at Gate 0.7 while a PRD is being prepared. It engages when the user says privacy notice, privacy policy, cookie policy, explicit consent, consent checkbox, personal data inventory, cross-border data transfer, GDPR compliance, "compliance check before going live", "is my landing page ready to publish", "SEO checklist" — even if the user never uses any of those exact words. It is not used for writing code, writing a PRD or giving general architecture advice. It is also not used for database decisions such as queries, indexes, schemas and column selection — those are left to prd-craft Gate D's writing boundary and are not answered here. JURISDICTION WARNING: the legal criteria in this skill are Turkish (KVKK, Law 6698) and apply to Turkey. It is not a substitute for GDPR or any other jurisdiction's rules.
argument-hint: "[application type or project scope — leave empty to let code scanning determine it]"
---

# kvkk-publish-review — Compliance Audit and Pre-Publishing Gate

This skill manages **two gates** and both have the same purpose: **to save the document from a
clean-looking audit report.**

1. **KVKK / Privacy Audit** — every job that collects, stores or processes personal data.
2. **Publishing Checklist** — every job that will go onto the public web.

> ⚠️ **JURISDICTION:** the legal criteria here are **Turkish law (KVKK, Law 6698)** and are
> written for **Turkey**. For a project outside Turkey, use this skill for its *mechanics*
> (data inventory, notice-vs-site comparison, consent enforcement evidence, publishing checklist)
> and replace every legal citation with the applicable jurisdiction's rules.

> **Philosophy:** A line being yellow, orange or red in an audit report is not a problem.
> There is exactly one problem: **it says "not checked."**
> Writing "Compliant" on an unchecked matter is more dangerous than writing no report at all,
> because it leaves an image of assurance behind.

---

## 0. The Core Rule

> **Without evidence, `Compliant` is not written.** Everywhere you are not sure, write
> `To be verified`. This report grants publication permission, so a "Compliant" written on a
> material matter **creates legal risk.**

| Status | What it means |
|---|---|
| `Compliant` | Evidence was shown and verified |
| `Gap` | What is missing is known, and what to do is written |
| `Conflict` | Two sources contradict each other (text ↔ site ↔ code) |
| `To be verified` | The check **was not performed.** It does not mean the check passed |

**"Bad", "risky", "should" is not a status.** The verdict goes in the "What to do" column.

---

## 1. Triggering — When This Skill Engages

`prd-craft` verifies one of two conditions at Gate 0.7 and calls this skill:

⛔ **The decision declaration is mandatory.** The first line of the answer:
`skill: <kvkk-publish-review | prd-craft | none> · rationale: <one sentence>`.
Table and ordering: `ROUTING.md`.

| Condition | Outcome |
|---|---|
| **Personal data declaration `YES`** (form · membership · newsletter · payment · analytics · pixel · session log · chat) | The KVKK audit is **mandatory** |
| Class `Publishing` (public web: landing page, corporate site, portfolio, documentation site) | The publishing checklist is **mandatory** |
| Neither | ⛔ This skill **does not run.** The rationale is written to the PRD |

> ⛔ **This skill does not engage on its own.** Without a personal data declaration the audit does
> not start. Saying "there is no data" is an **observation**; the declaration is taken **from the
> user** and recorded with its rationale — otherwise an audit applied to every project becomes an
> audit applied to none.
>
> **The Publishing class is not exempt from KVKK.** In the Publishing class the data axis may be
> `NO` only **with a written rationale** (e.g. "read-only documentation, no one-way data entry,
> verified by application type detection").

### What This Skill Does Not Do

- **It does not write a PRD.** `prd-craft` writes the PRD; this skill appends its output to it.
- **It does not write code.** If a finding is a gap it is written into the PRD as `Gap` + owner +
  date.
- **It does not make database decisions.** Query optimisation, index creation, schema and column
  selection are **code work** — out of scope here. If such decisions must be written they are
  left to `prd-craft`'s **Gate D writing boundary** (§0/6); they are not answered here.
- **It does not replace legal counsel.** The report states this explicitly.

---

## 2. Workflow

### Step 1 — Determine the Application Type

Read the **7-type matrix** in `references/kvkk-compliance-audit.md` §1. Without reading this file
it is impossible to tell which checks are `Mandatory` and which are `Conditional`.

### Step 2 — Scan the Code and Build the Inventory

Only what can be verified **by reading code** is written as `Compliant`. There are three sources:

| Source | Where from |
|---|---|
| **Code** | Form components, submit endpoints, external service calls, hosting configuration — `file:line` |
| **The published site** | Privacy notice, cookie policy, terms of use, form behaviour |
| **Panels** | Analytics, advertising, email service, payment provider accounts |

Method, evidence criteria, traps and browser steps:
`references/kvkk-compliance-audit.md`.

### Step 3 — Add the Compliance Blocks to the PRD

The blocks in `references/publishing-and-compliance-blocks.md` §A are added to §4 of the PRD's
technical constraints. These blocks are the **requirement** side: the decision "this information
will be written on the page" lives in the PRD.

### Step 4 — Produce the Audit Report

Fill in `templates/review-report.md`. **All four subsections are filled:**

| Subsection | May it be left empty? |
|---|---|
| Audit table | **No** — no row stays `To be verified` (an open question becomes a blocking open question) |
| Data inventory | **No** — if "no personal data is collected", that sentence is written on one line with its rationale |
| Not verifiable from code | **No** — the `To be verified` rows are moved here |
| Closing | **No** — the legal disclaimer paragraph is written **verbatim** |

### Step 5 — Fill the Publishing Checklist

Only in the `Publishing` class. Every tier in
`references/publishing-and-compliance-blocks.md` §B is filled. There is no shortcut — the only
way to shorten is to mark a row `Optional`, never to delete it.

### Step 6 — Link the Report to the PRD

The output is written as `docs/{feature}-kvkk-yayin-denetimi.md` and linked from §20 of the PRD by
file path. The PRD cannot declare itself "ready to publish" without the report.

---

## 3. The 8 Mistakes It Usually Makes

| Mistake | Symptom | Correction |
|---|---|---|
| **Unproven "Compliant"** | The report is entirely green without any scan | Without evidence write `To be verified` — that means not checked |
| **Template trap** | The notice exists in the document but not on the site (or the reverse) | The comparison is **bidirectional**; the difference is written as `Conflict` |
| **Single checkbox** | Notice and consent are merged into one `✓` | Separate checkboxes; consent must be withdrawable |
| **Service conditional on consent** | "Tick this so we can send you messages" | Responding must stay voluntary; marketing consent is separate, optional, **not pre-ticked** |
| **Assuming a banner is enough** | A cookie banner exists but the code loads before consent | It must be proven that **no request is sent at all** after a rejection |
| **"No data is sent"** | A pixel/analytics that "only counts visitors" | IP, redirect and session data are sent; the cross-border transfer is also written |
| **Legal page "later"** | "The KVKK text will be written after publication" | There is no going back; Tier A is a publication blocker |
| **Policy page = privacy notice** | "We have a privacy policy" | A policy page alone does not meet the obligation; it must state **which data, for which purpose, for how long** |
| **Personal data in logs** | `console.log(formData)` | Personal data is never written; a correlation id is enough |

---

## 4. Closing — Mandatory Legal Disclaimer

Every report closes with a **verbatim copy** of this paragraph:

> This review does not replace legal advice; the legal texts must be approved by the company
> itself, together with a lawyer where necessary.

---

## 5. Reference Files

| File | When it is read |
|---|---|
| `references/kvkk-compliance-audit.md` | Step 1 — application type matrix and the KV-01..KV-06 methods. **The gate is not considered passed without reading this file** |
| `references/publishing-and-compliance-blocks.md` | Steps 3 and 5 — the compliance blocks added to the PRD and the 8-tier publishing checklist |
| `templates/review-report.md` | Step 4 — the report skeleton |

---

## 6. Sources

- **KVKK privacy notice and cookie consent content (which headings are mandatory)** → KVKK 6698
  art. 5 · art. 10 · art. 11
- **Consent checkboxes, withdrawability, separation of marketing consent** → KVKK 6698 + the
  explicit consent criteria
- **Core Web Vitals thresholds (LCP 2.5 s · INP 200 ms · CLS 0.1, 75th percentile), sitemap + Search
  Console, canonical, robots.txt, soft-404, JSON-LD** → Google Search Central
- **`robots.txt` is a standard (RFC 9309) and AI crawlers honour it too; `llms.txt` is a proposal
  and its benefit is unmeasured** → RFC 9309 · Google AI features in Search