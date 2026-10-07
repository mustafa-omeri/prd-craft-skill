# Gherkin Rules — Writing Acceptance Criteria

> Read while filling PRD §14. Source: the current Cucumber / Gherkin standard. The rules here
> **write acceptance criteria**, they do not write code.

---

## 1. The Contract

| Keyword | What it does | What it must not do |
|---|---|---|
| **`Given`** | Puts the system into a known state | Mention user interaction |
| **`When`** | A single event or action | Several actions in a row |
| **`Then`** | An **observable** outcome | Behaviour buried inside the system (such as a database record) |
| **`And` / `But`** | Repeats a step of the same kind, for readability | — |

**The curtain metaphor:** behind the curtain the stage crew prepares — that is `Given`. The
curtain opens, the play begins — that is `When`. On stage one thing causes another and an
observable change happens — that is `Then`.

**A `Then` cannot check a record.** Looking at the database and saying "the record was created"
is tempting but wrong — the findings become fragile. Write the observable output.

> ⛔ **A `Then` with the state buried inside it is not written.** EARS' `State-driven` pattern
> (`While <state>, the System shall <response>`) is **not** an acceptance criterion on its own
> — it is a requirement pattern. When turning it into a `Scenario` the state is not buried in the
> `Then`; the state goes into `Given`, and the response is written as a separate,
> **observable** sentence in the `Then`:
>
> | ❌ State buried in | ✅ State in `Given`, response in `Then` |
> |---|---|
> | `Then the system approves while the order is in the "awaiting" state` | `Given the order is in the "awaiting" state`<br>`Then the order status becomes "approved" and the approval time is visible in the order details` |
>
> ⛔ If the `Then` says "it was written to the database", "the record was created" or "the
> service was called", it is **not** an acceptance criterion — write an observable output.

---

## 2. Rules

1. **Structure:** `Feature` > `Background` (shared Given) > `Scenario` >
   `Given / When / Then` (+ `And` / `But`).
2. **One behaviour:** a scenario tests **one** behaviour. The happy path, the edge case and the
   error are separate scenarios. Two independent quality concerns are not compressed into one
   scenario (main behaviour + performance + accessibility + security do not go in the same
   scenario).
3. **Write declaratively:** **write what is done, not how it is done.**
   Bad: `When I run an INSERT against SQL`. Good: `When I save a new search`.
   Do not write selectors, table names, endpoints or CSS classes — UI trends change far faster
   than the business rule, and those lines break the test.
4. **Fixed order:** Given (starting state) → When (action) → Then (observed outcome).
5. **Repeated data:** if the same flow is tested with different data, use `Scenario Outline` +
   an `Examples` table. Do not use an `Outline` when there is genuinely only one value.
6. **Shared precondition:** if a Given repeats in every scenario, move it under `Background`.
   But **`Background` must not exceed 4 lines** — if it does, move the unnecessary `Given`s out.
   If the condition is not truly shared by all scenarios, do not use `Background`.
7. **Tags:** put tags such as `@smoke`, `@mvp`, `@edge`, `@regression` on clusters that will be
   filtered.
8. **Be short:** a scenario should ideally be **under 10 steps**. A sensible range for one
   feature is **5-20 scenarios**.
9. **State, not navigation:** *"Given the user has logged in with the 'Editor' role"* >
   *"Given I went to the home page, logged in, clicked the dashboard and opened the settings"*.
10. **The scenario name must be specific:** "Product description is missing" is good · "Add
    Product, Log In, View Balance" is bad.
11. **Do not write vague outcomes:** "it works" / "it succeeds" → how it works must be stated.
12. **Add a negative criterion.** The most skipped and most expensive part: the system must
    **NOT** do this.

**The litmus test:** take the scenario, show it to someone who is not an expert in the domain
and ask "what does this do, can you explain it?" If they cannot, the scenario is broken.

**Independence:** every scenario must be meaningful and runnable on its own.

---

## 3. Example

```gherkin
Feature: Saved searches
  Users save complex searches and apply them with one click.

  Background:
    Given the user is logged in
    And there is at least one saved search

  @mvp
  Scenario: Applying a saved search
    Given there is a saved search named "Enterprise Q1"
    When the user clicks the search
    Then the URL parameters are updated with the search's query values
    And the dashboard data is reloaded with the new parameters

  @edge
  Scenario: Saving with an empty name
    Given the user presses "Save" in the search bar
    When they leave the name field empty and confirm
    Then an inline error is displayed
    And the popover does not close

  @edge
  Scenario: An unauthorised user accesses someone else's record
    Given there is another user's saved search
    When the user goes directly to that record's address
    Then access is denied and a 403 is displayed

  Scenario Outline: Applying across different datasets
    Given there is a saved search named "<name>"
    When the user clicks the search
    Then the result list shows <count> records

    Examples:
      | name          | count |
      | Enterprise Q1 | 42    |
      | Churn risk    | 7     |
```

---

## 4. How It Links to the PRD

- Every scenario is linked to a `US-N` identity; the pairwise checklist refers to that.
- The happy path + edge case + error state + **what must not happen** are separate scenarios.
- The checklist items produced from a scenario are numbered as `AC-NN` and linked to the
  `FR-NNN` requirements in §13. **An unlinked requirement is unnecessary; an unlinked checklist
  item is missing coverage.** The link must be bidirectional.