# Quality Checklist — Before Producing

> `prd-craft` SKILL.md §7. **Filled in after the PRD is written in Step 5, before delivery.**
> This section **does not score** — the single scoring point is Gate D.
>
> ⛔ Do not deliver without filling this list in. Then run `scripts/validate-prd.ps1`:
> ```powershell
> powershell -File .\scripts\validate-prd.ps1 -Path .\docs\feature-prd.md
> ```

---

## Gate B — Brief Gate *(filled BEFORE writing)*

> 🎯 Not a score, **yes/no**. If not all five are "yes", do not proceed to Step 5.
> Ask at most **2 rounds**; if it does not close, write it to §17 as an open question.

- [ ] **B1** Do the problem and the user come **from the user**? Was mirroring done?
- [ ] **B2** Is the success metric measurable? If there is a baseline, was it written?
      If not, was `[VERIFY]` **with its owner** written?
- [ ] **B3** Is there a scope boundary? Was it determined **without fabricating effort**?
      If effort is unknown, was the threshold recorded as **not computed**?
- [ ] **B4** Was the execution model decided? Does **every module have a single owner**?
- [ ] **B5** Were the technical constraints and the compliance gate decision made?

---

## Gates (the Gate 0 → Gate D projection)

- [ ] **Gate 0** the brief interview was done, **Channel A** (plain text) was used, mirroring was approved
- [ ] **Gate 0.2** if brownfield, the four things were looked at: manifest · tests · auth · UI
- [ ] **Gate 0.2** if the finding changed the decision, did you **go back to the decision** and tell the user?
- [ ] **Step 0** was the classification done and **told to the user**?
- [ ] **Gate 0.5** was the methodology chosen and **only that reference** read?
- [ ] **Gate 0.6** was the execution model asked? (§19.1 filled?)
- [ ] **Gate 0.7** was the compliance gate evaluated?
- [ ] If there was an unanswered question, was the §2.1 protocol applied? (on the third ask "skip deliberately")

## Content

- [ ] Is the JTBD → US → FR → AC chain linked **bidirectionally**?
- [ ] Are Anti-goals and Out of scope filled?
- [ ] Is every number **sourced** or `[VERIFY]` **with its owner**?
- [ ] Does every `[VERIFY]` / `[ASSUMPTION]` / `[NEEDS CLARIFICATION]` tag have an **owner and a
      target date**? (**Was `[to be assigned]` not written?**)
- [ ] Is there a negative criterion ("this must not happen")?
- [ ] Is the scope threshold **computable**, or is it recorded as not computed?
- [ ] Was the section that does not earn its place removed, with its **rationale in §21**?
- [ ] Were no line numbers, commit hashes or pasted code blocks written?
- [ ] Was module + interface + rationale used (instead of a file path)?
- [ ] Was a version number given, is the "Status" field current?

## Delivery and handover

- [ ] **If there is a runnable output, was the Delivery Gate run?** (§5)
- [ ] If there is no output, was the phrase **"This document is the deliverable, not code"** used?
- [ ] Were the run command, address, port and known limitations given?
- [ ] Was the **environment variable name** written instead of the password?
- [ ] Was no next step taken until the answer arrived?
- [ ] Was **`HANDOFF.md` produced or updated** at the project root?
- [ ] Is the §0 traps section of `HANDOFF.md` concrete — or does it say "no traps yet"?
- [ ] Can a new agent **continue with zero questions**?

## Deferred gate (if Gate 0.7 is open)

- [ ] §20 is **not empty** — has the gate name been written?
- [ ] Is the **owner a real person**? (`[to be assigned]` is forbidden)
- [ ] Has the **target date** been written?
- [ ] Is it stated which skill will be run?
- [ ] While the gate is open, was "ready to publish" **not** said?
- [ ] Is the gate listed as **open** in the delivery note?

## In a non-interactive environment (Channel C — cron / CI / batch)

- [ ] Were assumptions **not** applied silently?
- [ ] **If there was critical risk** (auth · data loss · personal data), was the process halted and
      the error written to `stderr`?
- [ ] At low risk, was every assumption written to `stderr` and the log as `[WARNING]`?
- [ ] **When an interactive user exists**, was Channel C not used?

---

## Closing

- [ ] Was the table in `references/common-mistakes.md` compared against the document?
- [ ] Did `scripts/validate-prd.ps1` **not report an error**?