# Publishing and Compliance Blocks

> There are two sections and both are appended to the PRD:
>
> - **§A — Compliance blocks to be added to the PRD.** These are the **requirement** side:
>   the decision "this information will be written on the page" lives in the PRD.
> - **§B — The publishing checklist.** This is a **task list**, not a requirement definition.
>   It is not a duplicate: it is the pre-publication form of §A.

---

# §A — Compliance Blocks to Be Added to the PRD

*(Appended to §4 Technical constraints of the PRD.)*

## A.1 Legal Pages — Which Text, Which Law, Whom It Protects

| Obligation | Scope | Legal basis | Who approves |
|---|---|---|---|
| Privacy notice | Which data, for which purpose, for how long, is there a cross-border transfer, explicit consent | KVKK 6698 art. 10 | Legal |
| Cookie consent | If there are analytics/pixel/session cookies, the accept-reject distinction + preference management | KVKK 6698 art. 5 (notice) + consent | Legal |
| Terms of use | The service contract; the right of withdrawal on a paid product | TKHK / distance contracts | Legal |

> **A policy page is not a privacy notice on its own.** A generic "our privacy policy" page
> that does not say which data is processed for which purpose does not meet the obligation. In
> the PRD, write **not the page name but which information will appear on that page.**

## A.2 Technical Indexing and Crawling (SEO)

- **`Canonical` policy** — if several URLs show the same content, one address
- **`sitemap.xml`** — which URLs are included/excluded, is it verified in Search Console
- **`robots.txt`** — what is blocked; **if `Disallow: /` is written by mistake the site stays
  out of the index**
- **Redirect rules** — `http→https`, `www↔non-www`, slug changes (301)
- **A non-existent URL returns a real `404`** — "not found" pages that return `200` get indexed
  as soft-404s and the SEO signal is poisoned
- **Structured data (JSON-LD):** `Organization` / `LocalBusiness` / `Service` / `FAQPage`
- **AI crawler rules** — `GPTBot` (training) and `OAI-SearchBot` (search), `ClaudeBot` /
  `Claude-SearchBot`, `Google-Extended` **are separate user agents**; blocking them all in one
  block also removes the site from answer engines

## A.3 Measurement (Analytics)

- Which tool (GA4, another) · which events (`page_view`, form submission, CTA click)
- **Its relation to cookie consent** — if analytics loads before consent it contradicts KV-05
- **Decision data point:** which decision is tied to which report (without a report there is no
  measurement)

## A.4 Infrastructure and Operations

- Domain ownership · SSL/HTTPS · backup scope (code + content + data) · error and uptime
  monitoring · renewal responsibility

## A.5 Performance (numbers are mandatory in the publishing class)

- **Core Web Vitals** — LCP ≤ 2.5 s · INP ≤ 200 ms · CLS ≤ 0.1, measured at the **75th
  percentile** and **on mobile** (a desktop lab result does not count)
- Image size/format (WebP/AVIF, lazy loading) · third-party script weight · font loading

## A.6 Compliance (separate for brownfield projects and the most critical)

- Does the existing API contract stay intact?
- Is it backward compatible with the existing data schema, or is a migration needed?
- Is the existing UI/UX consistency preserved?
- Is the existing performance characteristic preserved (e.g. "memory usage must not exceed
  20%")?

## A.7 Publishing Sub-surfaces (added to PRD §7 Experience)

| Surface | What must be written in the PRD |
|---|---|
| **Mobile view** | Which screens break at 360-414 px width, which flows exist/does not exist on mobile, is there horizontal scrolling |
| **Primary CTA** | **One** primary action per page; where it is visible, what its text is, where it leads |
| **Form behaviour** | Number of fields and whether all are required · what appears after submission · which field carries the error message · double-submit lock · spam/KVKK consent · verification code |
| **Images** | Which images have alt text, which are decorative (`alt=""`); do not write a meaningless `alt` outside the results page |
| **Error surfaces** | What the 404 page shows, whether it links to the home page · 500 · whether form data is lost when the connection drops |
| **Share card** | Open Graph + Twitter Card meta tags; image 1200×630, title and description the same as the page |
| **Site identity** | Favicon, `apple-touch-icon`, PWA manifest, `<html lang>` |

> **The primary CTA rule:** If there are two equally weighted buttons on a page, neither is
> chosen. If "Contact Us" and "Explore the Product" carry the same weight on the same page,
> that is an ambiguity — write it as `[NEEDS CLARIFICATION]` in the PRD.

---

# §B — Publishing Checklist

> This section is the **pre-publication form** of §A, of the §4 technical constraints and of
> the §13 measurable requirements. Every row is either `[x]` green or `[ ]` red —
> **nothing is left ambiguous.**

**How to use it:** Four columns are mandatory:

- **Evidence / target** — a number or an observable state. "It will look good" is not written.
- **Owner** — one single person. There is no row without an owner.
- **Applies** — `Mandatory` · `Conditional` · `Optional`. The condition of `Conditional` goes
  in parentheses.
- **Date** — the closing date (a date, not a day).

> **This section is not part of the scoring.** The score measures quality, this list **grants
> permission to publish**. Getting 90 points does not trigger this list; filling in only this
> list is not enough for publication either — **both are required.**
>
> **Do not delete rows.** If an item looks unimportant to you, write `Optional` and give its
> rationale in one sentence. A deleted item is a risk that is later not remembered and never
> asked about.

---

## Tier A — Legal Requirements *(publication blocker)*

| ID | Check | Evidence / target | Applies |
|---|---|---|---|
| YL-01 | **Privacy policy + privacy notice** — data controller, the data processed, purposes, retention period, cross-border transfer, explicit consent, rights | The published page + legal approval (KVKK 6698 art. 10) | Mandatory |
| YL-02 | **Cookie consent** — accept/reject distinction, preference management, cookie policy text | A record of **both** the accepted and the rejected flow (KVKK art. 5) | Conditional *(if there are marketing/analytics/pixel/session cookies)* |
| YL-03 | **Terms of use** — the service contract; the right of withdrawal on a paid product | The published page | Mandatory |

## Tier A-2 — KVKK Deep Audit *(mandatory when the data axis is `YES`)*

*Tier A asks "does the page exist"; this tier asks "is the page correct, is what really
happening what is written". Even if YL-01/YL-02 are green, if these rows are red there is a
publication blocker.*

| ID | Check | Evidence / target | Applies |
|---|---|---|---|
| KV-01 | **Data inventory** — every point that collects personal data, which field, where it goes, the legal basis, the retention period, the transfer | The audit report's data inventory table is filled; every row has file:line | Mandatory |
| KV-02 | **External services** — analytics, tag manager, pixel, session log, maps, video, external fonts, support, payment, email, hosting: which data goes, **is it cross-border** | For each service the data + country + purpose; the unused ones are written as "no data is sent" | Mandatory |
| KV-03 | **Privacy notice ↔ site comparison** — **bidirectional**: in the text but not on the site, on the site but not in the text; the complete art. 10 headings and art. 11 rights | The difference list is empty; every right has a counterpart in the implementation (e.g. a delete endpoint) | Mandatory |
| KV-04 | **Consent checkboxes** — the notice and the explicit consent are separate; responding is not conditional on consent; marketing consent is separate, optional and **not pre-ticked**; the record of consent is kept | A screenshot of the checkboxes + where the consent is recorded (text version, date) | Mandatory |
| KV-05 | **Does cookie consent really block** — after a rejection the analytics/pixel request **is not sent**; the decision is persistent; accept and reject are equally visible | An empty Network panel after a rejection + the recorded decision; a record of both flows | Mandatory *(if there is tracking/advertising)* · Optional *(if there are only strictly necessary cookies, with a rationale)* |
| KV-06 | **Security** — no plaintext personal data in logs; rate limit + captcha/honeypot; no embedded secret key; an authorization check on the endpoint that returns personal data | A log sample + an endpoint request (repeated without a session) + a key scan | Mandatory |

> **This table is not passed on its own.** The method, the evidence criteria, the traps and how
> to verify each row in the browser are in `references/kvkk-compliance-audit.md`; which
> application types make KV-01 `Mandatory` and which make it `Conditional` is determined by the
> **7-type matrix** there. **The `Applies` column is not filled without reading the matrix.**
>
> **The `Conditional` and `Optional` values from the matrix are written with a rationale.**
> Saying "there is no analytics" means `Optional` — but that means the row **closed**; it does
> not mean it was unchecked.

## Tier B — Publishing Infrastructure *(publication blocker)*

| ID | Check | Evidence / target | Applies |
|---|---|---|---|
| YL-04 | **HTTPS mandatory** + `http → https` **301** | 301 verified with `curl -I`, no invalid certificate | Mandatory |
| YL-05 | **A single host name** — one of `www` / non-www 301s to the other | The other address returns a one-way 301 (no duplicate content) | Mandatory |
| YL-06 | **301 for old URLs** — slug change, moved page, old campaigns | Every old URL returns a 301 to its current target; not 302/307 | Conditional *(if there is an old release/URLs)* |
| YL-07 | **A non-existent URL returns a real `404`** | A random URL returns `404`, not `200` (no soft-404) | Mandatory |
| YL-08 | **No page accidentally left out of the index** — staging/preview not reachable, `Disallow: /` not written, no leftover `noindex` | Verification with `site:` and URL Inspection | Mandatory |

## Tier C — Traffic and Conversion

| ID | Check | Evidence / target | Applies |
|---|---|---|---|
| YL-09 | **Mobile view** — no horizontal scrolling at 360/414 px, the CTA is visible, the form can be filled in | Device emulation + a record on a real device | Mandatory |
| YL-10 | **Core Web Vitals** — LCP ≤ 2.5 s · INP ≤ 200 ms · CLS ≤ 0.1, **75th percentile, mobile** | CrUX or RUM; desktop Lighthouse alone is **not** enough | Mandatory |
| YL-11 | **Image optimisation** — WebP/AVIF, size limit, lazy loading, `width`/`height` (a CLS source) | A format + dimension record for the main images | Mandatory |
| YL-12 | **A clear CTA** — one primary action per page, visible on the first screen, clear where it leads | One primary button per page | Mandatory |
| YL-13 | **Forms work** — the submission arrives, an error/success message appears, double submit is locked, validation is real, the KVKK consent checkbox is wired | An end-to-end registration: browser + server + delivery (email/CRM) | Mandatory |
| YL-14 | **Analytics installed and verified** — which events, which panel they land in, its relation to cookie consent | A test event visible in the panel | Conditional *(if measurement is wanted)* |

## Tier D — Search Engine Foundations

| ID | Check | Evidence / target | Applies |
|---|---|---|---|
| YL-15 | **Meta title + description** — per page, unique on every page, within the limit | A page list + a uniqueness check | Mandatory |
| YL-16 | **Canonical URLs** — one address for parameterised/multiple URLs | `rel=canonical` on the reviewed pages | Mandatory |
| YL-17 | **sitemap.xml** — only indexable URLs, submitted to Search Console | The GSC sitemap status + scope | Mandatory |
| YL-18 | **robots.txt** — what should be blocked is blocked; **AI crawler rules considered separately** (`GPTBot` training · `OAI-SearchBot` search · `ClaudeBot` / `Claude-SearchBot` · `Google-Extended`) | Verification with the Robots.txt Test tool; no AI bot block at the CDN layer | Mandatory |
| YL-19 | **A custom 404 page** — it directs the user to the home page or the relevant section | A 404 that stays in the address bar and gives links | Conditional *(if the site has 3+ pages)* |

## Tier E — Accessibility and Content

| ID | Check | Evidence / target | Applies |
|---|---|---|---|
| YL-20 | **Accessibility** — WCAG 2.1 AA: full use with the keyboard, visible focus, form labels, heading order, colour contrast | An automated scan **+ a manual keyboard/screen reader attempt** (the scan alone is not enough) | Mandatory |
| YL-21 | **Image alt texts** — descriptive on meaningful images, `alt=""` on decorative ones, `width`/`height` mandatory | A page count + a manual check | Mandatory |
| YL-22 | **Frequently asked questions** — real questions, marked up with `FAQPage` JSON-LD | Content + schema verification | Optional |
| YL-23 | **Structured data** — `Organization` / `LocalBusiness` / `Service` / `BreadcrumbList` | Rich Result Test | Optional *(Conditional if there is a local/corporate appearance)* |
| YL-24 | **Internal links** — breadcrumbs, related content, no dead internal links | A broken link scan + a site map | Conditional *(if it is a content site)* |

## Tier F — Brand and Secondary Surfaces

| ID | Check | Evidence / target | Applies |
|---|---|---|---|
| YL-25 | **Social sharing** — Open Graph + Twitter Card, a 1200×630 image, title/description | The share preview renders correctly | Optional |
| YL-26 | **Favicon + `apple-touch-icon` + manifest + `<html lang>`** | Tab, iOS home screen, language marking | Optional |
| YL-27 | **`llms.txt`** — `200` at the root, H1 + summary + links | *Its expected benefit is not proven, see below.* | Optional |

> **⚠️ Be honest about `llms.txt`.** This file is **not** the AI counterpart of `robots.txt` and
> is not an alternative to it — the two do different jobs and conflating them is a category
> error. `robots.txt` (RFC 9309) **restricts** who may read what and large crawlers honour it.
> `llms.txt` only offers a reading suggestion.
>
> **Measured situation (2026):** four independent studies found no benefit — on most wide-crawl
> crawlers the request rate for the file is below 0.1%, and on ~97% of publishing domains the
> file receives no request at all. Google states in its own documentation that Search **does
> not use** this file.
>
> **It is still marked `Optional`, because:** it costs ~1 hour, there is no observed harm and
> **there is a real use for developer documentation / code agents.** The only verifiable
> scenario: **count the `/llms.txt` requests in your own server logs.** If there are no requests
> in the log the file is not doing its job — that measurement must be written into the PRD.

## Tier G — The Ones That Die Silently After Publication

*This tier does not close on the publication day; the owner and the check period are written.
A responsibility is written, not a date.*

| ID | Check | Evidence / target | Applies |
|---|---|---|---|
| YL-28 | **Domain + SSL renewal responsibility** — who, at what period, where the reminder is | A renewal procedure before the expiry date | Mandatory |
| YL-29 | **Backup** — code + content + data; has a restore drill been done | At least one restore attempt | Mandatory |
| YL-30 | **Error and uptime monitoring** — nobody should learn that the form broke from a user | Sentry/telemetry + an uptime alarm | Conditional *(Mandatory if there is a form)* |

## Tier H — Depending on Context

| ID | Check | Applies |
|---|---|---|
| YL-31 | **Is the content rendered with JS?** — if so, verify that Googlebot can see it (URL Inspection) | Conditional *(Mandatory if there is an SSR/CSR distinction)* |
| YL-32 | **`hreflang` if multilingual** — reciprocal language tags, `x-default` | Conditional *(if there is more than one language)* |
| YL-33 | **Price/plan transparency** — what is free, what is paid, what is limited is written on the page | Conditional *(if there is a paid model)* |

---

## While Filling This Section

1. **Do not guess the evidence column.** If you have not measured it, write `Conditional` + who
   will measure it.
2. **The condition of a `Conditional` row is not a decision, it is a sentence.** "Conditional
   *(if there is e-commerce)*" is enough; the condition itself is tied to an owner and a date.
3. **`Optional` ≠ `Don't do it`.** An optional row is not out of scope; it waits with a decision
   record. The real out-of-scope is written in §4 of the PRD.
4. **Consistency is the PRD's job.** If a §3 saying "not targeted" contradicts this list saying
   "Mandatory", find out which of the document is correct — this is not a rejection of this
   list, it is **finding out which part of the document needs updating.**