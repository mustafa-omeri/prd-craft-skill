# EARS + RFC 2119 — Writing Functional Requirements

> Read while filling PRD §13. Source: EARS (Mavin et al., IEEE RE'09) + RFC 2119 / BCP 14.

---

## 1. Normative Language (RFC 2119 / BCP 14)

`MUST/SHALL` · `MUST NOT` · `SHOULD` · `SHOULD NOT` · `MAY` are used in the sense of
[RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) — **in uppercase only**. Written in lowercase
they carry their normal English meaning and lose their normative force.

Use these words **sparingly**: only when a requirement needs backward compatibility or harm
prevention. If every sentence has a `MUST`, the document is not a list of recommendations, it is
a bureaucracy file.

---

## 2. EARS Patterns

Every requirement contains **one sentence**, **one system name**, **one response**.

| Pattern | Pattern sentence | When |
|---|---|---|
| **Ubiquitous** | `The System shall <response>.` | True at all times |
| **Event-driven** | `When <trigger>, the System shall <response>.` | A result of an action |
| **State-driven** | `While <state>, the System shall <response>.` | Throughout a state |
| **Optional feature** | `Where <feature> is present, the System shall <response>.` | Feature flag / plan based |
| **Unwanted behaviour** | `If <unwanted condition> occurs, the System shall <response>.` | Error, exception, conflict |

In a complex pattern, preconditions and triggers **all come before** `shall`.

> ⚠️ **The problem EARS solves:** if you cannot find an `If-Then` requirement next to a `When`
> expression, there is probably a gap. Software fails in far more shapes than it succeeds.

---

## 3. Layer Discipline — the Most Common Mistake

> "`The System shall use a Redis cache`" is **not a requirement**; it is a design decision
> wearing a requirement's clothes — and it prevents the agent from proposing something better.

| ❌ Not a requirement (a design decision) | ✅ A requirement (an observable outcome) |
|---|---|
| The System shall use a queue | When an order is received, the System shall send the confirmation email within at most 60 seconds. |
| Data shall be cached in Redis | When the same query is run twice within 1 second, the System shall not hit the database on the second request. |
| React 18 shall be used | The list shall be visible in under 2.5 seconds at the 75th percentile on first load. |
| Passwords shall be hashed with bcrypt | When the password is changed, the System shall not allow login with a previously used password. |

The rule: **write the outcome the user can observe, leave the mechanism to the design.**

---

## 4. Requirement List Format

| ID | Requirement (EARS) | Story | Priority | Acceptance criteria | Version |
|---|---|---|---|---|---|
| FR-001 | The System shall validate that the name field is unique per user when a logged-in user saves a query. | US1 | P0 | AC-01, AC-04 | 1.0 |

**The `Acceptance criteria` column is not left empty.** Every `FR-NNN` is linked to at least one
`AC-NN` and every `AC-NN` is linked to at least one `FR-NNN`. **It is bidirectional.**

---

## 5. Measurable Technical Requirements

Speed, security, indexability and similar subjects are also written with EARS — they are not
hidden in a separate "technical appendix" section.

| Requirement | EARS sentence |
|---|---|
| Speed | `The requested page shall not exceed LCP 2.5 seconds, INP 200 milliseconds and CLS 0.1 at the 75th percentile on a mobile connection.` (unwanted behaviour) |
| HTTPS | `When a page request arrives over plain HTTP, the System shall redirect the request to the HTTPS address with a 301.` (event-driven) |
| Soft-404 | `When the requested record is not found, the System shall not return a 200 status code; it shall return a 404.` (unwanted behaviour) |
| Pre-consent loading | `If the user has not given their cookie preference before Analytics is loaded, the System shall not load the analytics script.` (state-driven) |
| Authorization | `When a user tries to access a record belonging to someone else, the System shall return a 403 and shall not display the record.` (unwanted behaviour) |
| Concurrent registration | `When two users register the same name at the same time, the System shall reject the second registration and show the user a conflict message.` (event-driven) |

---

## 6. The Rule on Writing Numbers

- If a number has a **source**, it is written with that source (RFC, standard, measurement).
- If it has no source it is marked with the `[VERIFY: ...]` tag and its owner and target date are
  written.
- A **category description** such as "fast", "efficient" or "acceptable" does not count as a
  requirement. An unmeasurable category description is not a requirement.

| ❌ Unclear | ✅ Measurable |
|---|---|
| Search should be fast and return relevant results | On a 10k-record dataset, search returns within 200 ms; Precision@10 ≥ 85% on the reference tests |
| The UI should be modern and easy to use | WCAG 2.1 AA; a Lighthouse accessibility score of 100 on the critical flows |
| Performance should be at an acceptable level | The p95 latency of the list page does not exceed 400 ms |
| Login should be secure | Authentication is wired to the existing auth service; an unauthorised request returns 403; the session expires after 30 min of inactivity |