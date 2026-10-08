# Roadmap

What is deliberately **not** done yet, and why. Everything here is a known gap, not an
oversight. If you close one, move it to the changelog in the commit that closed it.

---

## GDPR / EU track — **deferred**

`kvkk-publish-review` audits **Turkish law (KVKK, Law 6698)**. A **EU / EEA audience is not
covered.**

### What works today

The jurisdiction gate **is** in place. It does not pretend:

| Jurisdiction answer | Outcome |
|---|---|
| Turkish data subjects | The KVKK audit runs |
| EU / EEA data subjects | Gate closes, and the report says plainly that **this skill does not cover GDPR** and that legal review is required |
| Neither | Gate closes |
| Unsure | The skill asks before deciding |

**The mechanics are reusable.** The data inventory (KV-01), the bidirectional
notice-versus-site comparison (KV-03), the evidence that consent is actually enforced (KV-05)
and the publishing checklist (Tier A/B/C/D) are **jurisdiction-neutral**. A future GDPR track
can reuse them and only has to supply the legal basis, the rights list and the cookie rules.

### What a GDPR track would need

| Item | Turkish track (today) | EU track (missing) |
|---|---|---|
| Information notice | KVKK art. 10 | GDPR art. 13 / 14 |
| Data subject rights | KVKK art. 11 | GDPR art. 15-22 |
| Legal bases | KVKK art. 5/1, 5/2 | GDPR art. 6(1) |
| Cookies and terminal-equipment access | KVKK art. 5 + consent | **ePrivacy Directive art. 5(3)** + GDPR art. 6/7 |
| Sensitive data | KVKK art. 6 | GDPR art. 9 |
| Records of processing | — | GDPR art. 30 |
| Breach notification | KVKK art. 12 | GDPR art. 33 |
| DPO | — | GDPR art. 37 |

### Why it is deferred

The mapping is mechanical, but **the legal content is not**. Writing article numbers that look
authoritative without a lawyer checking them is exactly the failure this skill exists to
prevent — its own rule is *"without evidence, Compliant is not written."* It would be
inconsistent for the skill to invent GDPR citations in order to support GDPR.

⛔ **Do not add GDPR article numbers from memory.** Either have them checked by a lawyer and
cite the source, or keep the gate closed and honest.

---

## L1 evals are never scored automatically

23 behavioural cases are defined. L0 verifies the definitions; **L1 requires a human grader**
who did not perform the behaviour. There is no automation for this by design — see
[CONTRIBUTING.md](CONTRIBUTING.md).

⛔ An agent grading its own run is **not evidence**. `--grader same` means exactly that.

## More jurisdictions

CCPA/CPRA (US), LGPD (Brazil), PIPEDA (Canada), PDPA variants (Switzerland, Singapore,
Thailand, …) are all uncovered. Adding one means writing a new reference file, **not** editing
the KVKK one — see the "Adding a reference file" rule in CONTRIBUTING.md.