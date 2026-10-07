# Delivery Methodology — Sprint Agile (Scrum)

> This file is read **only when the user picks "Sprint Agile / Scrum" at Gate 0.5**, and PRD
> §19 is filled from the template in this file. The other methodologies:
> `delivery-mvp.md` · `delivery-kanban.md` · `delivery-waterfall.md`

---

## 1. When This Model Is the Right Choice

| Right choice | Wrong choice |
|---|---|
| Scope has clarified and the work can be broken into independent units | The "will it work?" question dominates and scope is still unclear |
| The team works at a steady pace and a regular rhythm helps | The team size changes frequently |
| Stakeholders expect regular feedback every 2-3 weeks | The delivery date is dictated externally in one shot |
| Everything remaining is visible and prioritisable | Scope must be presented as one fixed release |

> **A sprint is a learning unit, not an estimation unit.** At the end of a sprint what is gained
> is not "I did everything" but "I confirmed / refuted this assumption". The duration is two
> weeks, but what is **constant is not the sprint, it is the feedback at the end of the sprint.**

---

## 2. Mandatory Rules

1. **DoR (Definition of Ready)** is the condition for entering a sprint and is written into the
   PRD. A story that does not satisfy DoR is not put into the sprint — a "half-ready" story is
   the biggest burden on a sprint.
2. **DoD (Definition of Done)** is the definition of "done" and is written into the PRD. Work
   that is not in DoD does not count as "done"; if extra effort is needed to count as "done",
   DoD is incomplete.
3. **Slice independence:** every story entering a sprint must be testable on its own. Dependent
   stories cannot go into the same sprint.
4. **The sprint goal is a work output, not a work list:** not "US1, US2, US3 are done" but "A
   user can record a query and re-run it with one click."
5. **Measurement at the end of the sprint:** whether the sprint goal was actually reached is
   written. If it was not, **the reason is written** — a resultless rationale like "we were busy"
   is not accepted.

---

## 3. PRD §19 Template (Sprint Agile)

```markdown
### 19. Release and Delivery Plan — Sprint Agile (Scrum)

#### 19.1 Definition of Ready (DoR)
A story enters a sprint only when all of these hold:
- [ ] Its user and its benefit are written (role specific, not "user")
- [ ] The acceptance criteria are pairwise testable (there is a Gherkin scenario)
- [ ] Dependencies are resolved or do not block the sprint goal
- [ ] The design decision is made or no design is needed
- [ ] A rough size estimate exists
- [ ] Labelled: `[P0]` priority, `[US-N]` identity

#### 19.2 Definition of Done (DoD)
- [ ] The code is written and reviewed
- [ ] Unit + integration tests are green, new tests were written
- [ ] All Gherkin scenarios inside `US-N` pass
- [ ] The CI/CD pipeline is green
- [ ] Documentation is updated (README / API / PRD status field)
- [ ] No secret, key or personal data leaked
- [ ] `HANDOFF.md` is updated

#### 19.3 Sprint roadmap
| Sprint | Scope (US-ID) | **Sprint goal** (what do we learn?) | Size | Depends on |
|---|---|---|---|---|
| Sprint 1 | US1, US2 | | | — |
| Sprint 2 | US3, US4 | | | Sprint 1 |
| Sprint 3 | | | | |

#### 19.4 Remaining work (backlog)
| ID | Story | Priority | Why is it here? |
|---|---|---|---|
| US9 | | P2 | |

#### 19.5 Sprint cadence
| Event | Frequency | Duration | Output |
|---|---|---|---|
| Sprint planning | Start of the sprint | | |
| Daily sync | | | |
| Sprint review + retrospective | End of the sprint | | Goal actually achieved + reason for deviation |
```

> **While filling the template:** the sprint count and content are **not invented.** If the user
> only said "Sprint Agile", the sprint count and the size estimate are marked
> `[VERIFY: duration and team capacity were not given]` and §19.3 presents them as a
> "first sprint proposal".

---

## 4. Its Relation to the Execution Model (Gate 0.6)

If multi-agent was chosen, the sprint commitment is made **per slice, not per agent**: in the
Agent Execution Model section in PRD §19.1 it is written which agent works in which sprint and
whether the sprint goal is the responsibility of a single agent or of a combined output. If a
sprint goal is split across two agents and written half into each, that sprint definition is not
a requirement.

---

## 5. Common Mistakes

| Mistake | Symptom | Correction |
|---|---|---|
| **A work list instead of a sprint goal** | Sprint 1: US1, US2, US3 | Write the goal as a sentence; write a result, not a list |
| No DoR | "The sprint did not fit because it was not ready" | If DoR is missing, it is not a sprint planning error but a work preparation error |
| DoD = "the code is written" | Half-finished work is marked "done" | DoD covers tests, review and documentation too |
| Agile without sprints | "We are doing Agile" and one big delivery | Without sprints it is not Agile, it is a loose form of Waterfall |
| Invented durations | A date with no estimate is written into Sprint 2 | If the duration is unknown, `[VERIFY]` + a capacity question |
| Ignoring capacity | Three sprints worth of work at the same time on one agent | WIP/practical capacity for a single agent is **1** |