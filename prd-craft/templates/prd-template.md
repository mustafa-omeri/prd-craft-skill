# PRD Template — prd-craft

> This file is **not copied, it is filled in.** It is copied as `templates/prd-template.md`,
> and any section left empty is written into §21 with its rationale. **Sections that do not
> apply are not padded out and not deleted — but a deleted section is recorded in §21.**
>
> **These sections are never left empty:** §1 · §2 · §3 · §4 · §6 · §13 · §17 · §18 · §19 · §21
> **These sections are never skipped, the rationale is written to §21:** §5 · §7 · §8 · §9 · §10 · §11 · §12 · §14 · §15 · §16

---

# PRD: [Feature Name]

| | |
|---|---|
| **Version** | 1.0 |
| **Date** | [YYYY-MM-DD] |
| **Status** | Draft / Awaiting approval / Approved |
| **Owner** | [name] |
| **Quality score** | [result of Step 4] /100 |
| **Execution model** | Single coding agent / Multi-agent (N agents) — Gate 0.6 |
| **Delivery methodology** | MVP / Sprint Agile / Kanban / Waterfall — Gate 0.5 |
| **Compliance gate** | Not required / `kvkk-publish-review` engaged — Gate 0.7 |

---

## 1. Executive Summary

**Feature / Project Name:** [name]

**Problem Statement:** 2-4 sentences. Why it matters from the user's and the business's point
of view.

**Proposed Solution:** 1-2 sentences, without implementation detail.

**AI Build Summary:** a single paragraph in the imperative. What will be built, what the stack
is, what the hardest constraint is, what is not in the MVP. Example: "Build a Next.js 14 +
Supabase web app that lets users save and re-apply searches. No sharing in MVP. Must support
markdown export."

> An agent that skips this block starts without asking anything. It is the highest-yield
> section of the template.

---

## 2. Problem and Evidence

**Problem:** [The problem the user experiences, in the user's own words.]

**Affected segment:** [Who, how often.]

**Evidence:**
- [A measurement / log / support ticket / interview — with its source. "Users are struggling"
  is an **opinion**; "38% of trial users do not finish the setup wizard (Amplitude, Q2 2026)"
  is **data**.]

**If it is not solved:** [The cost of the missed opportunity.]

---

## 3. Goals and Success Metrics

**Primary Goal:** the single most important **outcome** in one sentence. Not an output — not
"build the onboarding wizard" but "cut the time to first value by 50%".

| Metric | Definition | Current (baseline) | Target | Window | How it is measured |
|---|---|---|---|---|---|
| | | | | | [which tool, which query] |

> Do not write a goal without a baseline — put `[VERIFY: baseline required]` and ask the user
> for it. A target is not measurable without its time horizon and its baseline.

**Lagging (outcome) metrics:** [-retention, revenue, reduction in support tickets]
**Leading (predictive) metrics:** [adoption, activation, task completion, error rate, duration]

**Threshold and target:** [The minimum acceptable threshold + the expected target. Not "high
adoption" but "within 30 days 30% of power users save at least one search."]

**Anti-goals:** what success explicitly **does not** include. Prevents scope drift.

> **Do not put a metric here that you will not measure.** A vanity metric is worse than none.

---

## 4. Scope, Priority and Constraints

### In scope (MoSCoW)

| Priority | Requirement | Rationale |
|---|---|---|
| **Must** | | "We would cancel the project without this" makes it a Must |
| **Should** | | It hurts but the solution survives (a temporary workaround is enough) |
| **Could** | | Wanted, low impact if removed — the **contingency pool** |
| **Won't (this time)** | | Deliberately outside |

> **If Must exceeds 60%, narrow the scope.** If everything is Must, then none of them is Must.

### Out of scope

Every row is a concrete statement + a rationale. Not "we will not build a CRM" but "no custom
template creation in this release; users choose from the ready-made templates."

**The rule for adding new scope:** Every addition must come with a **scope removal** or a
**calendar extension**. Ideas that are not reviewed use the parking lot in §19.

### Technical constraints

- **Platform:** web / iOS / Android
- **Auth:** the existing system, or a new dependency
- **Accessibility:** WCAG AA / AAA
- **Offline:** yes / no
- **Performance:** p95 latency, page load, concurrent users
- **Scale:** how many times the current load
- **Compliance:** data residency, GDPR / KVKK / SOC2

### Compliance record *(Gate 0.7)*

| Question | Answer | Where it is linked |
|---|---|---|
| Is personal data collected / stored / processed? | Yes / No | |
| Is there a public web release? | Yes / No | |
| Outcome | `kvkk-publish-review` engaged / not required | Rationale: |

> **In the Publishing class or when the data axis is `YES` this table is not left empty.** The
> detailed audit is the subject of the `kvkk-publish-review` skill and is appended to this PRD
> as a report.

---

## 5. Jobs to Be Done (JTBD)

Format: **"When [situation], I want to [motivation], so I can [expected outcome]".**
At most 2-5 jobs, ordered by frequency and importance.

| # | Job statement | Priority |
|---|---|---|
| J1 | | 1 |

> Job statements come before screen design. User stories are linked to this reference.

---

## 6. User Stories

A table linked to the JTBD.

| ID | Role | I want | So that | JTBD | Priority | Independently testable |
|---|---|---|---|---|---|---|
| US1 | | | | J1 | P0 | [can it be tested on its own?] |
| US2 | | | | J2 | P1 | |

> **Independent test:** would implementing US1 on its own produce something working and
> valuable? If not, you have made the stories depend on each other — split or merge them.

### US-N — [Title]

**Actor:** [a specific role — "corporate admin", not "user"]
**I want:** [the need, not a UI tool]
**So that:** [what it gains the user]

**INVEST check:**
- [ ] **I**ndependent — not dependent on the others
- [ ] **N**egotiable — the essence of the requirement is fixed, the solution path is flexible
- [ ] **V**alued — valuable to the customer (not only to the team)
- [ ] **E**stimable — understood well enough for a rough estimate
- [ ] **S**mall — a few person-weeks
- [ ] **T**estable — acceptance criteria can be written

**What this story must contain:**
- Main flow (happy path) · Empty state (when there is no data) · Error state (the operation
  fails)
- Edge cases (boundary values, concurrency, zero records)
- **What must be present:** [what the system must NOT do]

**Common story mistakes:**
- *Too vague:* "The product should be faster."
- *Imposing a solution:* "I need a dropdown list" — write the need, put the tool in §7.
- *No benefit:* "As an admin I want to see the report." — which decision will you make with
  this report?
- *Too big:* "I want to be able to manage the whole product." — that is not a story, it is a
  programme.
- *Team-internal:* "As an engineer I want to restructure the database." — that is a task, not a
  story.

---

## 7. Experience and States

*Mandatory for UI-heavy work; can be skipped for API/data-heavy work.*

**Design Direction:** [How does using it feel? Which mental model?]

**Key Screens / States:**
- **[Screen]:** [what it does]
- **Empty state:** [what the user sees when there is no data]
- **Loading state:** [skeleton / spinner / staged reveal]
- **Error state (load):** [what appears, what can be done]
- **Error state (save/operation):** [what appears, does the form close or stay open]
- **Validation error:** [where, with which message]

**Interaction Model:**
1. [steps]
- [Undo behaviour] · [Keyboard shortcuts]

**Accessibility Notes:**
- [Keyboard navigation, focus traps, focus return on cancel]
- [Screen reader: aria-label, aria-expanded, live regions]
- [Colour contrast ratio]

**Figma / Design Link:** [placeholder — link once the design is done. If it is not done,
`[VERIFY]`]

---

## 8. Component Inventory

`Component | Type | Description | Linked Stories` — so that AI component tools such as v0 and
Lovable can use it directly.

| Component | Type (Form/Layout/Action/Display/Navigation/Modal) | Description | Linked Stories |
|---|---|---|---|
| | | | US1, US2 |

List every meaningful part: form, card, modal, empty state, button, navigation, data table.

---

## 9. Data Models

Shape with a TypeScript interface. Comment any field that is not obvious. Without TS, a JSON
Schema or a plain field list.

```typescript
interface SavedSearch {
  id: string;            // UUID
  userId: string;        // FK, protected by the authorization check
  name: string;          // max 100 characters, unique per user
  queryParams: string;   // serialize URL params
  createdAt: string;     // ISO8601
  lastUsedAt: string;    // ISO8601
}
```

A one-line rule table for each field:

| Field | Type | Required | Rule | Example |
|---|---|---|---|---|
| | | | | |

`[VERIFY: uniqueness constraint — can the name repeat for the same user?]`

**Schema changes:** [which tables, which columns, which indexes, is a migration needed]

---

## 10. API / Integration Surface

| Method | Path | Description | Auth Required | Error | Response Shape |
|---|---|---|---|---|---|

If there is a BaaS (Supabase, Firebase), write table operations instead of REST endpoints.

**External integrations:** [which service, which SDK, which limits — rate limit, timeout, retry]

**Error contract:** [which error codes, which message to the user, which part is retried]

**Breaking change risk:** [is there one, who does it affect, migration plan]

---

## 11. State Management Map

`State | Location | Persistence | Notes` — so that it is known where each piece of state
lives and **why** it lives there.

| State | Location (Server/Local/URL/Auth/Cache) | Persistence | Notes |
|---|---|---|---|

---

## 12. Tech Stack Recommendation

Ask the user first, otherwise propose. `Layer | Choice | Rationale`.

| Layer | Choice | Rationale |
|---|---|---|

> **Anti-hallucination:** if you are proposing a new technology, add a current source link. If
> it cannot be verified, mark it "to be verified". A generic AI output that is not grounded in
> the product's own data is worse than a hand-written PRD.

**Suggested File Structure:** an ASCII tree with only the **changing** files. It is a target
skeleton, not a contract; do not list files that do not change.

---

## 13. Functional Requirements (EARS + RFC 2119)

Reduce the user stories here into **singular, numbered, testable** statements. This is the
most important section of the PRD. Writing rules: `references/ears-guide.md`.

| ID | Requirement (EARS) | Story | Priority | Acceptance criteria |
|---|---|---|---|---|
| FR-001 | The System shall validate that the name field is unique per user when a logged-in user saves a query. | US1 | P0 | AC-01, AC-04 |
| FR-002 | | | | |

**The bidirectional link is mandatory:** every `FR-NNN` is linked to at least one `AC-NN` and
every `AC-NN` to at least one `FR-NNN`. An unlinked requirement is unnecessary; an unlinked
checklist item is missing coverage.

---

## 14. Acceptance Criteria (Gherkin + pairwise checklist)

Every criterion must be testable as pass/fail. "Works correctly" is forbidden. Writing rules:
`references/gherkin-guide.md`.

### US1 — [Title] (JTBD: J1)

**Happy path**
```gherkin
Scenario: [a specific name that describes the behaviour]
  Given [a meaningful starting state]
  When  [a single action]
  Then  [an observable outcome]
```

**Error / edge state**
```gherkin
Scenario: [specific name]
  Given [state]
  When  [action]
  Then  [error behaviour — what appears, does the data change]
```

**Negative criterion**
```gherkin
Scenario: [what must NOT be done]
  Given [state]
  When  [action]
  Then  [the system does NOT do this — state it explicitly]
```

- [ ] [measurable criterion 1] → `AC-01` · `FR-001`
- [ ] [measurable criterion 2] → `AC-02` · `FR-001`
- [ ] [edge case: ...] → `AC-03` · `FR-002`
- [ ] [error state: ...] → `AC-04` · `FR-002`
- [ ] [what must be present: the system does NOT ...] → `AC-05` · `FR-003`

> **Do not skip the negative criteria.** "What must not happen" is the most expensive part to
> skip: was unauthorised access blocked, does a deleted record come back, what happens when two
> users register at the same time?

---

## 15. Test Decisions

**The definition of a good test:** it tests only **outward behaviour**, not internal detail.

- **Which modules** will be tested (chosen with the user in Step 4)
- **Where similar tests live** in this project, in what convention — give the path
- **Boundary and edge values:** [empty, single, many, maximum, negative]
- **Concurrency:** [what happens if two requests arrive at once]
- **Test data:** [fixture/seed strategy, identity data]

**Left out of scope:** [which behaviour will not be tested and why]. Writing down what will
not be tested is stronger than writing down why.

---

## 16. Behavioural Constraints

*This section is in no standard template, but it is the section that protects the system most.*

**What the system must NEVER do** — whatever the user asks for:
- [the limit, what the behaviour should be]

> "It should not hallucinate" does not work; an ambiguous instruction to an engineer produces
> the same result as an ambiguous prompt to a model: **noise that looks safe.** Write it like
> this instead: *"It must never cite a source that is not present in the supplied context."*

**Additionally, in a feature that involves AI / probabilistic behaviour:**
- **Evaluation strategy:** [how is success measured? LLM-as-judge? Human review? How many
  examples?]
  - *"A senior PM reviews 15 random outputs every sprint; if more than 2 fall below the quality
    line, the feature goes back to prompt iteration."* — This sentence is a testable contract.
    *"It should be correct and concise"* is not.
- **Safety numbers:** [hallucination rate < 3%, coverage score > 85%, etc.]
- **Failure modes:** [written by examining real outputs, not by guessing]
- **Safe refusal:** [on which input it says what]
- **Uncertainty marking:** [in which situation it signals that it is unsure]
- **Fallback behaviour:** [when the model is wrong: does it fail, warn, or escalate to a human?]

> **Do not write failure modes by guessing.** The best failure modes are found by examining
> prototype outputs. **The order is this: first see the system succeed, then write the
> contract.**

---

## 17. Risks, Open Questions

### Risks

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| | High/Med/Low | High/Med/Low | |

### Open questions

| Question | Blocking? | Owner (PM/Eng/Design) | Target date |
|---|---|---|---|
| | Yes / No | | |

Resolve the blocking ones one by one. Defer the non-blocking ones with an "owner + condition for
revisiting".

### Trade-offs accepted

- [What was given up, why, what was received in return]

---

## 18. Concept Glossary

Was "customer", "account", "member" or "subscriber" used in the conversation? Does "cancel"
mean cancelling an order or ending a subscription? Fix the terms in one table; otherwise the
document silently merges two concepts.

| Term | Definition | Other names | ID |
|---|---|---|---|

---

## 19. Release and Delivery Plan

> This section is filled in **according to the methodology chosen at Gate 0.5.** The
> template and the rules are in the relevant reference file:
>
> - **MVP** → `references/delivery-mvp.md`
> - **Sprint Agile (Scrum)** → `references/delivery-agile.md`
> - **Kanban** → `references/delivery-kanban.md`
> - **Waterfall** → `references/delivery-waterfall.md`
>
> **The templates of the three unchosen methodologies are not copied into this section.**
> Writing all four models means a delivery plan without a methodology.

**Chosen:** [MVP / Sprint Agile / Kanban / Waterfall] · **Rationale:** [why this one]

### 19.0 Common Delivery Rules

*(The chosen methodology's own table is copied from the reference above. Only rules that apply
to every model are written here.)*

- **Slice traceability:** the PRD is broken into **end-to-end thin slices** in the work tracking
  system — each slice must pass through all of the schema → service/API → UI → test layers and
  **must be testable on its own.** Every slice carries a `US-N` reference; that is how
  traceability is established from the PRD to the code.
- **Sign-off:** [ ] Product Lead · [ ] Engineering Lead · [ ] Design · [ ] Compliance/Legal
- **Next steps:** [action] — *Owner: [name], Date: [date]*
- **Technical debt:** when you may ask the agent for a proposal:
  when **no** item marked `[NEEDS CLARIFICATION]` remains **and** every `AC` is pairwise
  testable.
- **Session handover:** after the PRD is approved and before code development starts, the
  `HANDOFF.md` at the project root is updated. The newly arrived agent reads this file first
  (especially the §0 traps and the §3 first commands).

---

## 19.1 Agent Execution Model *(Gate 0.6 — mandatory)*

> This subsection is written in **every PRD.** A delivery plan cannot be operated before it is
> known which agent (or agents) will implement this PRD.

### Execution model: [Single coding agent / Multi-agent (N agents)]

| Field | Value |
|---|---|
| Number of agents | [1 / N] |
| Agent names and specialisations | [Agent-1: backend · Agent-2: frontend …] |
| Shared source of context | [PRD · ADR · knowledge-base.md · reference files] |
| Shared contract | [which interface/contract is the single source of truth for all agents] |

### Module responsibility map

| Module / slice | Responsible agent | Interface (what it produces) | Who consumes this interface |
|---|---|---|---|
| | | | |

> **In multi-agent this table is mandatory and is not left empty.** Every module must have a
> single owner. The answer "anyone can do this module" means one agent writes it twice and the
> other overwrites it.

### Dependencies and order

| Module | Waits for | Waited on by |
|---|---|---|
| | | |

- **With a single agent:** the order is the single list itself. If the modules are not
  independent the dependency order is written and **one agent works on one module at a time.**
- **With multiple agents:** the modules that can run in parallel are separated from those that
  **must** be serial. The serial ones go to the merge gate.

### Merge gate (integration gate)

| Criterion | Where it is verified | Status |
|---|---|---|
| Interface/contract tests are green | | |
| Both sides' acceptance criteria pass | | |
| Integration test | | |

- **Order:** [which module is merged first, why]
- **Outcome verification:** one end-to-end scenario, who will run it

### Conflict points and decision owner

| Conflicting area (same file / same schema / same text) | Who decides | Rule |
|---|---|---|

### Be careful about coupling between the implementing agent and the other agents

| Topic | Rule |
|---|---|
| Two agents writing to the same file | Forbidden — file ownership belongs to a single agent |
| Two agents touching the same schema/migration | Forbidden — a migration has a single owner |
| A contract change | Only the contract owner changes it; the other agents **wait for approval** |
| Who updates shared state | A single source; see §11 State Management Map |

---

## 20. Compliance Audit *(only when `kvkk-publish-review` is engaged)*

> This section is **not the subject of this skill.** If the data axis or the publishing class is
> triggered at Gate 0.7, a separate skill is run and its output is appended here.

| Status | File / report | Date |
|---|---|---|
| Personal data inventory | | |
| External services and transfers | | |
| Legal texts | | |
| Publishing checklist | | |

**Report link:** [the audit report file path]

---

## 21. Assumption Record and Appendices

**Unused sections:** [which sections were not written in this PRD and why — **every skipped
section is on record.**]

**Assumptions:** [a summary of the `[ASSUMPTION]` tags used in the document. If the table is
empty, write "no assumptions".]

| # | Assumption | Why it was assumed | Verified by | Target date | What changes if it is wrong |
|---|---|---|---|---|---|
| | | | | | |

**Appendices:** [Figma, prototype, related PRDs, decision records, benchmark results]