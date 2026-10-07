# Delivery Methodology — Kanban (Continuous Flow)

> This file is read **only when the user picks "Kanban" at Gate 0.5**, and PRD §19 is filled
> from the template in this file. The other methodologies:
> `delivery-mvp.md` · `delivery-agile.md` · `delivery-waterfall.md`

---

## 1. When This Model Is the Right Choice

| Right choice | Wrong choice |
|---|---|
| Priorities change often and there is no fixed sprint rhythm | The release date and delivery boundary are dictated externally |
| Team members work on different things in parallel | Every piece of work depends on the output of the previous one (the queue jams) |
| Continuous delivery is already normal (deploy every day) | Deployment is infrequent and risky (every deploy is an event) |
| The number of waiting items is constant and suits a pull model | If work is constantly started and left half-finished, Kanban does not solve that, it only makes it visible |

> **Kanban is not a rhythm, it is a flow constraint.** There is no sprint; work is pulled the
> moment it is ready. The question "when will this story start" is not asked; the question "when
> will it be ready to finish" is asked.

---

## 2. Mandatory Rules

1. **The WIP limit is mandatory.** The number of simultaneous items per column is limited. When
   the limit is full, no new work is started — what is in progress is finished first.
2. **An unlimited queue is forbidden.** The "remaining work" list stands in priority order with
   a decision criterion; the period for re-evaluating the order is written down.
3. **Independent stories are mandatory.** The only thing standing in front of a card waiting in
   the flow is a WIP limit. That is why every card must produce value on its own.
4. **The measurement comes from the flow itself.** The Cycle Time and Lead Time definitions are
   written in the PRD. A metric without a threshold is just as much a fake number here.
5. **When the WIP limit is full, new work is rejected.** This is the exception; the rule "start
   it because a request came in" does not apply here.

---

## 3. PRD §19 Template (Kanban)

```markdown
### 19. Release and Delivery Plan — Kanban (Continuous Flow)

#### 19.1 Flow columns and WIP limits
| Column | Purpose | WIP limit | When the limit is full |
|---|---|---|---|
| Preparation | Work not yet clarified | [N] | No new work is taken |
| Development | | [N] | |
| Review / Test | | [N] | |
| Ready to release | DoD not verified | [N] | |
| Released | | — | |

> **Why are the limits these numbers?** [Rationale — e.g. "there are 3 agents, one item each"]
> Without a rationale the limit number is marked `[VERIFY]` and the user is asked.

#### 19.2 Card priority queue
Priorities may change; **the change rule is written down.**
| Rank | US-ID | Priority | Decision criterion | Last reviewed |
|---|---|---|---|---|
| 1 | | P0 | | [date] |
| 2 | | P1 | | [date] |

#### 19.3 Flow metrics
| Metric | Definition | Target | How it is measured |
|---|---|---|---|
| **Cycle Time** | The time from a card entering "Development" to leaving "Ready to release" | ≤ [X days] | [tool] |
| **Lead Time** | The time from a request entering the queue to release | ≤ [X days] | [tool] |
| **Throughput** | Number of cards completed per unit of time | ≥ [N/week] | [tool] |
| **WIP count** | Average simultaneous cards | ≤ [N] | [tool] |

> **No number means no target.** A target number is not written before the measurement tool is
> chosen; without a measurement it is `[VERIFY]` + the question "who will make this measurement?"

#### 19.4 Continuous delivery
| Trigger | The step that runs automatically | Verification |
|---|---|---|
| When a card enters "Ready to release" | [test → package → deploy] | [smoke test step] |

#### 19.5 Remaining work
| US-ID | Priority | Re-evaluation trigger |
|---|---|---|
```

---

## 4. Its Relation to the Execution Model (Gate 0.6) — important

Kanban and multi-agent are **the most natural match.** That is why, if the answer at Gate 0.6
is "multi-agent" and Kanban was chosen, the PRD's Agent Execution Model section must state:

- **Every agent is a WIP slot.** "Agent A's limit is 2" means that agent holds at most 2 items
  at the same time; this row is written explicitly.
- The **WIP limit is shared across agents** — not 3 agents × limit 2 = 6 in total, but as many
  as the team's total limit. Read wrongly, the flow jams.
- The **more agents there are, the higher the integration cost**; that is why the interface
  contract between slices (§ Agent Execution Model) is locked earlier in Kanban than in
  Waterfall.

---

## 5. Common Mistakes

| Mistake | Symptom | Correction |
|---|---|---|
| **Kanban without WIP limits** | There are columns but no ceiling | Write a number for every column; stop when the limit is full |
| **Claiming continuous delivery without continuous delivery infrastructure** | Every merge goes live, no tests | The trigger + verification row is not left empty |
| Card dependency | A card waits for the output of card A and is queued after A | Dependent work is isolated and split into two independent items |
| Cycle Time undefined | "It gets finished fast" | Definition + target + measurement tool, all three together |
| Team WIP mistaken for agent WIP | Each agent applies its limit for itself | The total limit is written on a single row in the PRD |
| Invented metrics | Targets exist but there is no measurement tool | Without a tool the target is `[VERIFY]` and the rationale is asked |