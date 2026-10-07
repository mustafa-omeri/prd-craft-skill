# Delivery Methodology — MVP (Tracer Bullet)

> This file is read **only when the user picks "MVP" at Gate 0.5**, and PRD §19 is filled
> from the template in this file. The other methodologies:
> `delivery-agile.md` · `delivery-kanban.md` · `delivery-waterfall.md`

---

## 1. When This Model Is the Right Choice

| Right choice | Wrong choice |
|---|---|
| The idea is not yet proven and the "can we do this?" question dominates | There is a corporate contract and an audit obligation |
| User numbers or traffic cannot be estimated | Sector regulation fixes the delivery date |
| Fast feedback matters as much as scope safety | The team is already bound to a fixed deliverable list |
| Scope is still disputed; what is valuable is not clear | There are many stakeholders and pleasing all of them dominates |

> **MVP does not mean smaller scope. MVP means testing the riskiest assumption with a real user
> as quickly as possible.** The motivation is learning speed, not scope reduction. It is MVP
> because you test risk early, not because you shrank the scope.

---

## 2. Mandatory Rules

1. **Scope threshold:** `Must` requirements together may not exceed **60%** of the total effort.
   If they do, narrow the scope. If everything is `Must`, then none of them is `Must`.
2. **One vertical slice:** first write **a single thin slice** that runs end to end (a tracer
   bullet) — schema → service/API → UI → test layers, *all of them* present in this slice. No
   layer may be deferred to "the second week".
3. **Parking lot rule:** everything that falls outside the slice is written to the §19 "Phase 2+"
   list. It does not leak into the body. An idea that leaks into the body silently widens scope.
4. **The verification criterion is mandatory:** a single observable criterion is written for MVP
   to count as "it works" (measurement tool + threshold + time window). Without a criterion the
   MVP is not a release, it is an unfinished product.

---

## 3. PRD §19 Template (MVP)

```markdown
### 19. Release and Delivery Plan — MVP

**Strategy:** The thinnest end-to-end vertical slice first, everything else to the parking lot.

#### 19.1 Scope threshold
| Item | Value |
|---|---|
| Total Must count | [N] |
| Estimated total effort | [X] |
| Must share | [%] — **must not exceed 60%** |
| Decision | [Musts kept / these 3 Musts dropped] |

#### 19.2 Tracer bullet — the first slice
| Layer | Scope | How we know it is done |
|---|---|---|
| Schema | | |
| Service / API | | |
| UI | | |
| Test | | |

**One-sentence definition of the slice:** [The user can do X and see Y.]
#### 19.3 Slice order
| # | Slice | Evidence of value (what does this slice teach us?) | Depends on |
|---|---|---|---|
| 1 | | | — |
| 2 | | | 1 |

#### 19.4 Verification criterion (when does the MVP count as "it works")
| Criterion | Measurement tool | Threshold | Time window |
|---|---|---|---|
| | | | |

#### 19.5 Phase 2+ — parking lot
Does **not** leak into the body. Every row carries a "look again trigger".
| # | Idea | Trigger (what makes it be reconsidered) |
|---|---|---|
| P1 | | |
```

---

## 4. Its Relation to the Delivery Gate

Because in the MVP model the slices are **individually deliverable**, the Delivery Gate (§5)
runs separately at the end of every slice: the user is asked "this slice is working, would you
like to try it?", and work does not proceed until the answer arrives.

---

## 5. Common Mistakes

| Mistake | Symptom | Correction |
|---|---|---|
| Fake MVP | Scope is halved but the first slice is still not end to end | If the schema → API → UI → test path is missing from the slice, this is not an MVP, it is a shortened product |
| **Feature reduction** | It is called "MVP" and some of the existing features are removed | MVP shortens the *path*, it does not lower quality. It is the **flow** that is shortened, not the features |
| MVP without a criterion | "Users will be satisfied" | Without a criterion the MVP is not release-ready; §19.4 is not left empty |
| Parking lot leak | A 5th idea enters the body with "let's also add this" | Every addition comes with a scope removal or a calendar extension |
| Too many Musts | Must at 70%+ | Re-apply the scope threshold |