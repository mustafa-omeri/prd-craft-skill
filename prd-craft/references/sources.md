# Sources and Methodology Reference

> A `prd-craft` SKILL.md reference. The relevant ones of these sources are written into §21
> Appendices of the PRD.

---

## Sources

| What was taken | Source |
|---|---|
| Documentation first, code after · the judge/elaborate split · the execution model · the session bridge | **Mustafa Ömeri Scope & PRD Framework** |
| Discovery, deep modules, the test decision, the "no file paths / no code writing" rule | `prd-yaz` (leaf) |
| JTBD · AI Build Summary · Component/Data/API/State · two-layer AC | johnnychauvet |
| The 100-point quality gate · the 90 threshold · the risk matrix · inflation | McpMarket (Sarah) |
| A PRD is the product of a conversation · the PRD → issue chain | Matt Pocock `write-a-prd` + `prd-to-issues` |
| The Gherkin contract · `Background` · `Scenario Outline` · tags · declarative writing | Cucumber / Gherkin docs |
| EARS patterns · RFC 2119 / BCP 14 · layer discipline | EARS (Mavin et al., IEEE RE'09) + AWS Kiro |
| Non-goals · "if everything is Must then none of them is Must" · Must ≤ 60% · parking lot · INVEST | Anthropic `feature-spec` + DSDM MoSCoW |
| `[NEEDS CLARIFICATION]` · `[ASSUMPTION]` · the `FR-00N` traceability schema | GitHub spec-kit |
| Vague ↔ concrete example pairs · the TBD ban · the separated critique context | GitHub awesome-copilot `prd` + superpowers |
| Evaluation strategy · behavioural constraints · deriving failure modes from real outputs | Adaline AI |
| Baseline + window + measurement method table · "an unmaintained PRD is bad" | Vantage / aioproductos |
| Scaling length to risk · the "do not invent sections" rule | BMAD-METHOD |
| Choosing a question tool · the ban on silent assumptions in critical decisions | `prd-yaz` (leaf) |
| **The 500-line SKILL.md limit · progressive disclosure · negative triggers** | Agent Skills best practice (skill anatomy) |

---

## Sources of the Compliance Skill

| What was taken | Source |
|---|---|
| Privacy notice and cookie consent content (which headings are mandatory) | KVKK 6698 art. 5 · art. 10 · art. 11 |
| Consent checkboxes · withdrawability · separation of marketing consent | KVKK 6698 + the explicit consent criteria |
| Core Web Vitals thresholds (75th percentile, mobile) · sitemap + Search Console · canonical · robots.txt · soft-404 · JSON-LD | Google Search Central |
| `robots.txt` is a standard (RFC 9309) and AI crawlers honour it too · `llms.txt` is a proposal and its benefit is unmeasured | RFC 9309 · Google AI features in Search |
| The KVKK audit method · the 7 application type matrix · the KV-01..KV-06 evidence criteria | `kvkk-publish-review/references/kvkk-compliance-audit.md` |

---

## Why None of Them Is Enough Alone

- The process-oriented ones miss **measurement**.
- The template-oriented ones miss **the conversation** — the agent fills in the form without
  learning the intent.
- Those who know methodology well miss **hallucination**.
- Those who audit miss **the decision** — writing the document correctly is not enough to pass
  the gate; the intent also has to have been captured correctly.

The value of this skill is in the combination.