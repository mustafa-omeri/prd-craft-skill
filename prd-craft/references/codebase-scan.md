# Codebase Scan and Personal Data Inventory

> A `prd-craft` SKILL.md reference. Read during **Gate 0.2 (pre-scan)** and **Step 2 (full
> scan)**. This file carries the tables for both stages; the flow stays in SKILL.md.

---

## 0. The difference between the two stages — why we look twice

| Stage | When | What it looks at | Purpose |
|---|---|---|---|
| **Gate 0.2 — pre-scan** | **Before** the methodology decision | Manifest, main modules, existing tests, existing auth, is there a UI | **Ground the decision in code reality** |
| **Step 2 — full scan** | **Before** the module decisions | All of the above + architecture, conventions, configuration, external services, personal data points | **Everything needed to write the document** |

> 🎯 **This separation is deliberate.** Information missing at Gate 0.2 grounds the methodology
> decision wrongly. Live evidence from testing: that the frontend **does not exist at all** was
> seen at Gate 0.2; had it been seen later, "building the UI layer from scratch" would have been
> written into the first slice from the start.

---

## 1. Gate 0.2 — Pre-scan *(brownfield)*

Brownfield detection: at the root `pom.xml` · `build.gradle` · `package.json` ·
`pnpm-workspace.yaml` · `pyproject.toml` · `requirements.txt` · `go.mod` ·
`Cargo.toml` · `*.csproj` · `pubspec.yaml` · `Podfile`

No manifest → greenfield, this gate is **skipped**, the stack is asked of the user.

### The four things to look at

| Look at | What the outcome changes |
|---|---|
| **Manifest + main modules** | The language/stack is already clear — **re-proposing one is wrong** |
| **Existing tests** | Background on "tests are written like this in this project"; it feeds the test-module question in Step 4 |
| **Existing auth / authorization** | **Without auth** authentication becomes `Must` or a blocking prerequisite. **If permissions only look at role**, project-level ACL is a `Must` candidate |
| **Is there a UI** | **Without one**, "inside the existing app" means a new install; UI languages are determined by asking about the stack |

### Findings that can change the decision

A finding is reported to the user **before** Gate 0.5:

- No UI → UI languages are determined **by question** (as in greenfield)
- No auth → `Must` or a blocking prerequisite
- Authorization missing → ACL `Must`
- External service/pixel in the manifest → the compliance gate **opens**

> ⛔ **This gate does not invent decisions.** Report what you saw as-is; write your
> interpretation on a separate line.

---

## 2. Gate 0.5 — Gathering Evidence for the Methodology *(optional)*

MVP's rule that the "first slice includes all of the schema → service → UI → **test** layers"
makes the first slice impossible when the project has **no test infrastructure**. That is why
the presence of tests is also checked at Gate 0.2.

---

## 3. Step 2 — Full Scan

### Universal manifest list

| Family | Manifest |
|---|---|
| Java | `pom.xml`, `build.gradle`, `settings.gradle` |
| Node.js / TypeScript | `package.json`, `pnpm-workspace.yaml`, `tsconfig.json` |
| Python | `pyproject.toml`, `requirements.txt`, `Pipfile`, `setup.py` |
| Go | `go.mod`, `go.sum` |
| Rust | `Cargo.toml` |
| .NET / C# | `*.csproj`, `*.sln` |
| Mobile | `pubspec.yaml` (Flutter), `Podfile` / `build.gradle` (React Native) |

**Also find in every scan:** existing architecture · auth structure · conventions · existing
tests · configuration (`application.yml`, `.env.example`, `docker-compose`) · migration history.

### The verification rule — show a source for every claim

| Situation | How it is written |
|---|---|
| If you verified it against code | `src/modules/saved-search/search.service.ts:112-140` |
| If you could not verify it | `[VERIFY: "..." — not verified]` + **owner + date** |
| If it is your inference | `[ASSUMPTION: ...]` + **owner + date** |

> ⛔ `"Owner: [to be assigned]"` **is not written.** The owner is the user themselves or a real
> person's name. An ownerless tag blocks delivery (`scripts/validate-prd.ps1`).

### Uncertainty labels (Step 2b)

| Label | Meaning |
|---|---|
| `[ASSUMPTION: ...]` | You inferred something without confirmation |
| `[VERIFY: ... — source/ownership]` | The claim is real but has no evidence |
| `[NEEDS CLARIFICATION: ...]` | Stop if you cannot proceed without an answer; mark it if it can be answered |
| `[CONFLICT: ...]` | Two sources contradict each other — it stays marked until resolved |

---

## 4. Personal Data Collection Point Inventory

**Only when the data axis is `YES`**, and done in **the same scan** as the architecture
exploration — not in a separate round. Doing it in a separate round makes the scan invalid as
soon as the code changes.

| What to look for | Why |
|---|---|
| Form components and submit endpoints | Which fields are collected, where they go |
| Membership / login / profile screens | Account data, password reset |
| Newsletter, campaign, "subscribe" | A typical point requiring explicit consent |
| Order / payment / address | The highest-volume personal data |
| Appointment, reservation, support ticket | Time and place data |
| Email service, WhatsApp, live support | Personal data leaving for a third party |
| Analytics / pixel / session log / maps / video | Silent points that make cross-border transfers |
| Hosting, CDN, payment, email provider | Where the data **physically** resides |

> This inventory is the **raw source** for the compliance audit report. Do not invent a
> collection point you did not find — mark it `[VERIFY]` and hand it to the compliance skill.