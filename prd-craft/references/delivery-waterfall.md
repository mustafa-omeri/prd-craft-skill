# Delivery Methodology — Waterfall (Phased / Gated Enterprise)

> This file is read **only when the user picks "Waterfall / phased" at Gate 0.5**, and PRD
> §19 is filled from the template in this file. The other methodologies:
> `delivery-mvp.md` · `delivery-agile.md` · `delivery-kanban.md`

---

## 1. When This Model Is the Right Choice

| Right choice | Wrong choice |
|---|---|
| Sector regulation or audit records dictate the phases | Scope has not yet clarified and the "will it work?" question dominates |
| The contract, the signature and the acceptance criteria are fixed externally | The delivery date changes as a surprise |
| Each phase's output is the next phase's input and must be traceable | The team is small and the same person does all the phases |
| Change management and sign-off are mandatory | A "redesign" decision is taken every two weeks |

> **In Waterfall, documentation is the deliverable.** The transition between phases is the event
> "the previous phase's output was signed off"; an unsigned transition is a rule violation. That
> is why the sign-off matrix in §19.3 cannot be left empty.

---

## 2. Mandatory Rules

1. **Each phase's completion criterion is measurable.** "Design is finished" is not enough;
   "approved schema + contract + wireframe" is measurable.
2. **A phase transition happens with sign-off.** The name of the approver is written for each
   phase. Without an approver the phase is not a "gate" but a checkpoint — which one it is must
   not be left ambiguous.
3. **The go-back rule is written down.** Going back to a previous phase is not an accident but a
   process: when, with whose approval and at what cost.
4. **Change control is mandatory.** A scope change cannot be made without a written request and
   an impact analysis. This is one of Waterfall's only purposes.
5. **The phase output definition is written down.** Each phase's *deliverable* is named in one
   sentence. A phase that cannot be named must not be separated out.

---

## 3. PRD §19 Template (Waterfall)

```markdown
### 19. Release and Delivery Plan — Waterfall (Phased)

#### 19.1 Phases and milestones
| Phase | Scope | Output (deliverable) | Owner | Completion criterion | Sign-off |
|---|---|---|---|---|---|
| Phase 1: Analysis | | Business analysis document | | | [name] · [date] |
| Phase 2: Design | | Schema + API contract + wireframe | | | |
| Phase 3: Development | | Core modules + integration | | | |
| Phase 4: Test / QA | | End-to-end test + security + performance report | | | |
| Phase 5: UAT | | User acceptance test report | | | |
| Phase 6: Go live | | Staging rehearsal + prod deployment + backup | | | |

> **The number and names of the phases change by project type.** If left empty it is marked
> `[VERIFY: phase breakdown was not given]` and the user is asked.

#### 19.2 Entry/exit criteria (gates)
| Transition | Entry condition | Exit condition | Evidence |
|---|---|---|---|
| Analysis → Design | | | [file] |
| Design → Development | | | |
| Development → Test | | | |
| Test → UAT | | | |
| UAT → Live | | | |

#### 19.3 Sign-off matrix
| Role | Name | Responsibility | Scope of approval | Date |
|---|---|---|---|---|
| Product lead | | | | |
| Engineering lead | | | | |
| Design | | | | |
| Compliance / legal | | | | |

#### 19.4 Change control (Change Request)
| CR No | Date | Requested change | Impact (scope/duration/cost) | Approver | Status |
|---|---|---|---|---|---|
| CR-001 | | | | | Pending / Approved / Rejected |

**Rule:** No phase's scope may be changed before a written CR is approved. A scope change
**always** affects either a phase output or the calendar.

#### 19.5 Go-back rule
| Reason | Which phase is returned to | Who approves | Cost |
|---|---|---|---|
| | | | |

#### 19.6 Delivery dates
| Milestone | Date | Dependency | Note |
|---|---|---|---|
| | | | |

> **Without a source for the date it is not invented.** An estimated date is marked `[VERIFY]`
> and the acceptance criterion it is based on is written.
```

---

## 4. Its Relation to the Execution Model (Gate 0.6) — important

If multi-agent was chosen, parallelism can be set up **within** a phase, but **not between**
phases — because the next phase's input is the previous phase's signed output. In the PRD's
Agent Execution Model section:

- For each phase it is written **which agents work in that phase** and **who the single owner
  of the phase gate is.**
- If a phase gate is split across two agents it becomes unclear whose signature it is; this is
  the most common mistake of the Waterfall + multi-agent combination and is prevented by the
  single "Approver" column in §19.3.

---

## 5. Common Mistakes

| Mistake | Symptom | Correction |
|---|---|---|
| **Fake Waterfall** | "Waterfall" is claimed and there are 40 changes in 3 weeks | If the change frequency does not support this model, recommend MVP/Agile — but the decision is made by the **user** |
| No completion criterion | "Phase 2 is finished" | A name for an observable output for every phase |
| Sign-off without a signer | The approver column is empty | The row is not left empty; without a signer the phase is undefined |
| Invented dates | Milestone dates with no basis | Without a source for the date, `[VERIFY]` |
| Change control is skipped | Scope changes by email | The CR record is mandatory; verbal changes are not accepted |
| The test phase's content is unclear | "Phase 4: test" | What is tested is written: acceptance criteria, performance or security |
| The execution model is not written | Which agent works in which phase is unclear | The Agent Execution Model section is mandatory |