# KVKK / Privacy Compliance Audit — Reference

> **When it is opened:** when the **data axis** in §2 Step 0 is answered `YES`.
> Data axis: "Does this work collect, store or process personal data **or** touch a system that
> collects it?" — if the answer is `YES` this reference is read and the §20.1 report is
> produced. If the answer is `NO` it is written to §21 with its rationale.
>
> **This reference defines the gate rows (§20 Tier A-2) and explains how they are evidenced.**
> The evidence produced is written to PRD §20.1.

---

## 0. The Single Rule of This Reference

**Without evidence, `Compliant` is not written.** Extrapolating is the most expensive mistake
in a legal audit: a report that appears to have passed but is actually incomplete is worse than
no report at all — because the company believes it was "checked". Everywhere you are not sure,
write **`To be verified`**.

This is the report-level counterpart of the `[VERIFY]` tag in §2b. The `To be verified` column
means "not checked" — it is not arbitrarily cleaned up to make the audit look finished.

### Status legend — four values, nothing else

| Status | What it means | Acceptable evidence |
|---|---|---|
| **Compliant** | The requirement is met **and** its evidence is in the report | A code line, a page URL, a measurement record |
| **Gap** | The requirement is entirely absent | The absence itself is the evidence (`file:line` = —) |
| **Conflict** | Two pieces of evidence contradict each other | Both pieces of evidence are in the report (text ↔ site, code ↔ text) |
| **To be verified** | The evidence was not seen or is not embedded in the code | Who, when and how will check it |

**"Bad", "risky", "should" is not a status.** A status is an observation; the interpretation
goes in the "What to do" column.

---

## 1. Application Type Matrix (7 types)

The type determines **how many** of the audits are mandatory — not **which** audit does not
apply. An audit that does not apply becomes `Optional` and its rationale is written in one
sentence (see the "Do not delete rows" rule in §20).

`M` = Mandatory · `C` = Conditional · `O` = Optional (with a rationale)

| Application type | KV-01 | KV-02 | KV-03 | KV-04 | KV-05 | KV-06 | The single most missed item |
|---|---|---|---|---|---|---|---|
| **Static / corporate web** (landing, corporate site, portfolio, documentation) | M | M | M | M | C | O | Analytics/pixel **not mentioned at all** in the text — the code loads it, tracking happens, the privacy text is silent |
| **Web application** (membership, login, panel) | M | M | M | M | M | M | Plaintext email / phone / password in logs; and the **data controller–data processor distinction in SaaS never being written** |
| **E-commerce / payment** | M | M | M | M | M | M | Not counting the payment provider (iyzico, PayTR, Stripe) as a "recipient of transfer" |
| **Backend / API service** (invisible to the user) | M | M | C | O | O | M | Retention period and **unauthorised endpoints**; log masking assumed to be there |
| **CLI / CI work** (terminal tool, pipeline, bot, code agent) | M | M | C | O | O | M | ⛔ **SSRF** — every target the tool **requests on its own**; and **unlimited cross-border transfer** (the targets depend not on the code but on the **data content**) |
| **Mobile** (iOS / Android) | M | M | M | C | O | M | Permission ↔ KVKK mapping and the data collected by **third-party SDKs** (an in-app SDK inventory) |
| **WordPress / ready theme** | M | M | M | M | M | C | **The plugin list = the external service list** — a plugin was added, the text was not updated |

#### ⛔ If it does not fit any row fully — record the deviation

The matrix does **not** fit every application into a row. Choose the closest row, **write the
deviation in two sentences at the top of the report** (which row was chosen · what was paid),
and **do not close the audit.** The most common deviations:

| Situation | Closest type | The audit that changes |
|---|---|---|
| A tool that does not host endpoints and makes requests on its own (CLI, CI, bot, code agent, sync job) | Backend / API | KV-06/5 "unauthorised endpoint" is replaced by an **SSRF** audit: allowlist/denylist, the RFC1918 · loopback · link-local block, the `file://`/`gopher://` block, the **redirect hop limit** |
| An internal tool that uses the desktop/terminal and has no UI | Backend / API | KV-04 · KV-05 become `Optional` + **a one-sentence rationale** (no form, no browser, no cookies, no consent mechanism) |
| A tool that collects no data and only reads **existing** data | Web application | KV-01 is still **Mandatory** — the data read enters the inventory and can carry the **identity** characteristic |
| A bulk job without identity (bulk sending, synchronisation) | Web application | There is no data subject in KV-01, but the **recipient list** and the **rate limit** enter KV-06 |

> ⛔ **Writing the deviation without a rationale and skipping the audit is not the same thing.**
> The verdict "KVKK does not apply to this tool" is **the law's job, not yours.** Your job is
> **to make what is processed visible** — then leave the decision to the law.

**SaaS / multi-tenant product is not a separate type**, it is the most critical variant of the
"Web application" type and it additionally makes these three mandatory:

1. **Who is the data controller and who is the data processor?** In multi-tenant SaaS the
   tenant is the controller and the provider is the processor (or the reverse). If this
   distinction is **not written** in the privacy notice and the contract the audit is a `Gap` —
   if you do not know which role you have taken, you cannot know the privacy notice either.
2. **The list of subprocessors** — sub-hosting, payment, email, SMS providers.
3. **Retention and deletion** — when the tenant's data is deleted after the account closes.

### How the type is detected from the code

| Clue | Type |
|---|---|
| No `next.config`, there is an `index.html`, no server-side rendering | Static/corporate web |
| There is a `login`, `register`, `session`, `auth` module/endpoint | Web application |
| `cart`, `checkout`, `order`, `payment`, `stripe`/`iyzico`/`PayTR` | E-commerce |
| Only API/Controller/Service, no UI, the user arrives from inside | Backend/API |
| ⛔ **None of these match** — there is a `package.json`/`bin`, `process.argv` is read, there is a `.github/workflows/` or a `Jenkinsfile`, it **makes requests on its own** with `fetch`/`axios`/`curl`, it does not listen on a server/port | **CLI / CI work** |
| `Info.plist`, `AndroidManifest.xml`, `Podfile`, `build.gradle` | Mobile |
| `wp-content`, `functions.php`, `wp-config.php` | WordPress |

> ⛔ **"There is no UI" does not mean "Backend/API".** There are two different classes without a
> UI: those that **serve** (listen on a port, accept requests) and those that **make their own
> requests** (CLI, CI work, bots, synchronisation). The second is not `Backend/API` but the
> `CLI / CI work` class — because the real risk is **not unauthorised access but reaching
> somewhere on its own initiative (SSRF).**

---

## 2. KV-01 — Data Inventory

**Purpose:** find **every** point that collects personal data and write it into the inventory.
An incomplete inventory means an incomplete privacy notice.

Collection points to look for (all of them):

- Forms (contact, quote, registration, login, comment, support ticket, survey)
- Membership / account creation (profile fields, password reset)
- Order / payment (address, card, phone)
- Newsletter / campaign subscription (**one-click** registration is especially risky — see
  KV-04)
- Appointment / reservation
- Support channels: **WhatsApp**, live support widget, email, contact form
- Comment / star rating, IP recording, device fingerprint
- File upload (avatar, document, payment proof)
- Credit application / contract / declaration form (if any — **the highest risk class**)

The fields to record for each point:

| Field | Description |
|---|---|
| **Collecting point** | The form name / endpoint (file:line) |
| **Fields** | Which personal data fields (name, email, phone, address, TR national ID, KVKK No, IP, location, health, special category data) |
| **Where it goes** | Database (which table/schema) · email service · WhatsApp/API · CRM · analytics · payment provider |
| **Legal basis** | Contract · explicit consent · legal obligation · legitimate interest · **if there is special category data, explicit consent separately** |
| **Retention period** | How long, who deletes it |
| **Transfer** | Is it cross-border, which country/service |

> **Special category data (KVKK art. 6):** health, race, ethnic origin, religion, political
> opinion, trade union membership, biometric, genetic, sexual life. These require **separate,
> explicit consent**; the rationale "necessary for the service to work" is not accepted. They
> should not be asked in the form design at all.

---

## 3. KV-02 — External Services and Data Transfer

For every external service **three** columns are mandatory: which data goes, **in which country
it is processed**, and for what purpose. Even the "no data is sent" row is written — because
the real question is not "is there one" but "are you aware of it".

The list of services to check (partial — whichever of these is used):

| Category | Services |
|---|---|
| Measurement | Google Analytics 4, Google Tag Manager, Mixpanel, Amplitude, Plausible, Matomo |
| Advertising / pixel | Meta (Facebook) Pixel, Conversions API, TikTok Pixel, LinkedIn Insight, Google Ads |
| Session recording / heatmap | Microsoft Clarity, Hotjar, FullStory, LogRocket |
| Maps / location | Google Maps, Mapbox, Yandex Maps, OpenStreetMap |
| Video | YouTube/Vimeo embedded player |
| External fonts | Google Fonts, Adobe Fonts, Bunny Fonts — **a character selector sends IP + user agent** |
| Social / sharing | Share buttons, embedded posts (a send button makes a request on first load) |
| Live support | WhatsApp widget, Crisp, Intercom, Tawk.to, Zenvir |
| Form/CRM | Formspree, HubSpot, Mailchimp, Brevo, Google Forms |
| Payment | iyzico, PayTR, Param, Stripe, PayPal |
| Email | Resend, SendGrid, Mailgun, Postmark |
| Hosting / CDN | Vercel, Netlify, Cloudflare, AWS, Hetzner, DigitalOcean |
| External APIs | OpenAI, Anthropic, OCR, maps, shipment tracking, WhatsApp Business API |

> **Cross-border transfer** (KVKK art. 9) is not a service choice matter, it is a **legal
> requirement**: if data is transferred abroad the text must state **which country** it is
> transferred to and the **legal basis**. Writing "cloud" does not explain a transfer.
> `[VERIFY: the provider's country of data processing — the contract/service terms must be
> examined]`

> **The "no data is sent" misconception in pixels and analytics:** the page address, the
> referrer, the form fields (even hashed they can be matched by IP), session logs, screen
> recordings and mouse movements are typically sent. "It only counts total visitors" is
> technically true and legally misleading.

---

## 4. KV-03 — Privacy Notice ↔ Cookie Policy Comparison

The core of this audit is the **template trap**: every statement that is in the text but not on
the site (or exactly the reverse) counts as an inconsistency. The comparison is bidirectional
and **must be done in both directions**:

- **A → B:** Does every piece of data or service mentioned in the text really exist on the site?
- **B → A:** Does every data collection or external service that runs on the site appear in the
  text?

### Mandatory headings (KVKK art. 10)

| Heading | If missing |
|---|---|
| Who the data controller is, its address, its contact | The text is legally considered invalid |
| Which personal data is processed | Compared with the KV-01 inventory |
| Processing purposes (purpose + the prohibition of use outside the purpose) | "To improve service quality" is not a purpose on its own |
| The legal basis (with the article number) | Contract / explicit consent / legal obligation / legitimate interest |
| Recipients and **cross-border transfer** | It is a gap if the country + legal basis is not written |
| Technical measures for data security | |
| The retention period, or the criterion for determining it | |
| **The rights of the data subject (art. 11)** | The list below |

### Art. 11 rights — are they all written?

- Requesting information · requesting correction / **deletion** of your data ·
- Requesting restriction of processing · requesting compensation for harm ·
- **learning the third parties your data was transferred to**
- **being re-informed if the legal basis changes**
- **the outcome in the case of automated processing**

> If the rights list is copied but **there is no counterpart in the implementation** this is a
> `Conflict`: a "you have the right to deletion" statement with no delete endpoint or flow is a
> false statement.

### Cookie policy

A list of cookie names alone is **not enough**: for each cookie **the purpose, the duration and
the provider** are required. For advertising/marketing cookies **category-based** consent is
additionally required.

> **If there is a cookie policy text there must also be a cookie consent, and the reverse is
> also true.** If one exists and the other does not, that is a `Conflict` — the most frequently
> missed inconsistency.

### If the page does not exist

If the policy/notice page **does not exist**, do not leave it blank: the row becomes `Gap` and
the evidence reads `Page not found`. "The legal team is preparing it" is not a status, it is a
temporary note, and it is written as `To be verified` + owner + date.

---

## 5. KV-04 — Consent Checkboxes

Four questions; if all four are `Gap` it is a publication blocker:

| # | Question | Compliant | Non-compliant |
|---|---|---|---|
| 1 | **Are the notice and the explicit consent in a single box?** | Separate checkboxes or a readable link to the text | Both merged into one `✓` |
| 2 | **Is consent required just to receive a reply?** | Responding stays voluntary; consent is an offer, not a condition | "Tick this so we can send you your message" |
| 3 | **Is marketing consent separate and optional?** | Separate, can be left empty, **not** pre-ticked | Mandatory · pre-ticked · "force it to remove it" |
| 4 | **Is the record of consent kept?** (text version, date, IP, how) | There is a record | No evidence → withdrawability cannot be proven |

> **Why separate checkboxes are mandatory:** **showing** a privacy notice and **giving** explicit
> consent are different acts. If the two are merged in one box, the consent is not considered
> to have been obtained in a provable and separable way — and it is not withdrawable.
>
> **A pre-ticked box** is that explicit consent? No. CMPs that use only the "ticked box =
> approval" pattern count the user as consenting without touching anything. That is implicit
> consent, not explicit, and it is not refusable.

> **Only in a contact form:** email/phone for a question-answer ("we'll get back to you", "we'll
> call you") is mandatory for the performance of the service — a consent checkbox is not
> required here and is even unnecessary. By contrast consent **is** required for **marketing**
> (newsletter, campaign). Merging the two into one box is the most common mistake.

> **Legal basis:** Explicit consent is the condition foreseen by KVKK art. 3 (definition:
> "consent declared freely and explicitly") and art. 5/1 for data that is **not** of a special
> category.
> `[VERIFY: the current practice of the written-form requirement and the withdrawal obligation
> for explicit consent — let the law approve it]`

---

## 6. KV-05 — Cookie Consent: Does It Really Block?

**Drawing a banner is not obtaining consent.** The real thing to check is that when it is
rejected, **no request goes out at all**.

### What to look for in the code

| Check | Correct | Wrong |
|---|---|---|
| Default consent state | `setDefaultConsentState({ analytics_storage: 'denied', ad_storage: 'denied', ... })` | No definition → the browser cookie counts as **allowed** |
| Update at the moment of the decision | `updateConsentState(...)` / `gtag('consent', 'update', ...)` | The banner exists, the state is never updated |
| Tag load order | The consent decision comes **before the tag** | GTM/gtag loads, the banner appears afterwards |
| Trigger | In GTM a default with `Consent Initialization`; the tracking tags are bound to the consent signal | There is no "there is currently no consent" check |
| Persistence of the rejection | The decision is stored and applies even after a page reload | It is asked again on every page or the decision is lost |

> **Common trap — `addConsentListener`:** this listener only fires when the permission changes
> between `denied ↔ granted`; it does **not** fire on the `unset → granted` transition, because
> `unset` counts as "granted". This is the most frequent cause of a "the listener is there but
> analytics never arrives" complaint. If the default value is *not* `denied` the listener
> silently never works. A user who rejected is mistakenly counted as "granted".
>
> **Common trap — advanced Analytics:** in Analytics' *advanced* implementation, even when
> `analytics_storage: denied`, **cookieless pings** are sent. This is technically permitted, but
> it breaks the "I clicked reject and nothing goes out" test. The audit additionally asks which
> implementation was chosen.

### The "Reject" flow — the test

After a rejection, **all four** of these must hold:

1. The consent cookie is not `granted` (the banner does not reappear)
2. There are **no** analytics/pixel/external requests in the Network panel
3. There is no third-party request for that session in the server access log
4. If cookies are listed in the browser there are **only** the strictly necessary ones

If any of these does not hold the status is `Conflict` (you are telling the user "you can
reject" but it is not being rejected).

> **Accept and reject in one click:** the "Accept" and "Reject" buttons must be of equal
> visible size and in an equal position. A "Reject" that is small, grey and in the corner does
> not mean the consent is given **freely** under KVKK art. 5/1.

---

## 7. KV-06 — Security

| # | Check | What is looked for |
|---|---|---|
| 1 | **Personal data in logs** | Are email, name, phone, address, TR national ID, password or token logged in **plaintext**? |
| 2 | **Rate limit** | Is there a rate limit on the form submission endpoint? |
| 3 | **Bot protection** | Captcha or a **honeypot** (an invisible field — if it is filled, the request is rejected) |
| 4 | **API key** | Is there a key embedded in the code (the client bundle is readable) |
| 5 | **Unauthorised access** | Is an endpoint that returns personal data open without authentication |
| 6 | **Retention path** | Does personal data also remain in backups, logs, cache and the file system |

> **The log trap:** `console.log('Form submitted', formData)` or `logger.info("user", user)` writes
> permanent plaintext personal data. What is worse, it automatically goes to third-party error
> tracking services (Sentry, LogRocket). Masking (`a***@b.com`) or **not writing it at all** is
> required; a correlation id and the field **names** are enough.
>
> **The key trap:** A "public" key embedded on the client side (a Stripe publishable key, the
> Firebase configuration) is required by design and is not counted as a `Gap`. A **secret** key
> ending up in the bundle is a `Conflict` and the key requires **rotation**.
>
> **The open endpoint trap:** `GET /api/orders/{id}` where only `id` is guessable and there is no
> authentication/authorization check is **not an acceptable finding** — it is a `Conflict` and is
> closed immediately. The finding is written together with its severity and the remediation
> procedure.

---

## 8. Report Contract — Output Format

The audit report is written to PRD **§20.1** in the following order. No section is closed
without a heading, an item, a file or evidence, a status, the required action, the owner and
the target date.

### 8.1 Main Audit Table

```markdown
| # | Item | File:line | Status | What to do |
|---|---|---|---|---|
| KV-01 | Data inventory — the contact form collects name, email, phone | `src/features/contact/ContactForm.tsx:24-38` | Compliant | — |
| KV-01 | Data inventory — date of birth in the booking form (may be special category) | `src/features/booking/BookingForm.tsx:51` | Gap | Remove the field or add the art. 6 explicit consent text |
| KV-02 | Meta Pixel loads, "advertising" does not appear in the privacy notice | `index.html:31` ↔ `/privacy` | Conflict | Add it to the text or bind the pixel to the consent checkbox |
| KV-03 | The art. 11 rights are not in the privacy notice | `/privacy` | Gap | Add the rights list to the text |
| KV-04 | The marketing consent is pre-ticked | `src/features/newsletter/Newsletter.tsx:19` | Conflict | Remove `defaultChecked`; do not make the box binding |
| KV-05 | After a rejection no analytics request goes out | `ConsentBanner.tsx:41-60` | Compliant | — |
| KV-06 | The password is logged in plaintext | `src/services/auth.service.ts:88` | Conflict | Mask the value; rotate the key |
```

**Writing `file:line` — the §3 exception.** The body rules forbid "writing a file path and a
line number" because the PRD body goes stale over time. **§20.1 is an exception:** the audit
report is an **instantaneous snapshot of the moment of review** and must be traceable. That is
why the line number is written here — and the note `Audit date: <date> · Scope:
<commit/branch>` is put at the top of the report.

### 8.2 Data Inventory Table

```markdown
| Data | Collecting point | Where it goes | Legal basis | Retention | Transfer |
|---|---|---|---|---|---|
| Name, surname, email | Contact form | Table `contact_requests`, email service (Resend, US) | Contract (art. 5/1) | 6 months after the request closes | Resend — US, based on contract |
| TR national ID | Contract signature | Table `contracts` | Legal obligation (art. 5/2) | Contract duration + 10 years | — |
| Email | Newsletter registration | Mailchimp, US | Explicit consent (art. 5/1) | Until the subscription ends | Mailchimp — US, based on explicit consent |
```

### 8.3 Not Verifiable From Code

This section is **not left empty.** Every item that cannot be verified from code is written
here, together with the browser/panel step:

```markdown
| Item | Why it cannot be verified from code | How to check it in the browser | Who / When |
|---|---|---|---|
| Whether the pixel really fires after consent in GTM | The GTM container and tags are not in the repo but in the GTM interface | GTM Preview → check the "Consent Initialization" trigger; Reject → no request should appear in the network panel | |
| Whether Analytics was set up in advanced or basic mode | Not in a config file | GA4 Admin → Data stream → Identity/Consent settings | |
| Whether the retention period is actually applied | Not in the software code | Create a sample record → is it deleted after 6 months | |
```

### 8.4 The End of the Report — Mandatory Closing

The report closes with a **verbatim** copy of the following paragraph:

> This review does not replace legal advice; the legal texts must be approved by the company
> itself, together with a lawyer where necessary.

---

## 9. Browser / Panel Verification Procedure

These steps prove what the code cannot show. What each maps to in the report is written.

| What | How |
|---|---|
| **Which external services load** | DevTools → **Network** → reload the page → group the request list by domain. Separate the advertising/tracking/session recording requests |
| **Code loaded before consent** | Set the preferences panel to **Reject**, then **clear** the Network and reload. If an analytics/pixel/map request arrives, the banner is ineffective |
| **The cookie table** | DevTools → **Application → Cookies** → the domain; everything except those marked "required in comparison" is unnecessary |
| **Local storage** | Application → **Local Storage / Session Storage / IndexedDB** — is an analytics id or form data held |
| **Is the decision stored** | Reject → reload the page → if the banner comes back the decision is not persistent |
| **External font / embed IP leak** | Network → requests to `fonts.googleapis.com`, `youtube.com`, `maps.googleapis.com`, `connect.facebook.net`; if these go out before consent it is a KV-05 violation |
| **Where the contact form goes** | Submit the form → Network → the POST target, the payload fields, the returned URL |
| **Personal data falling into logs** | Submit the form → the application console and the server log; then the same event in an error tracking panel such as Sentry |
| **An open endpoint** | With a victim user's session open, take the request URLs from the Network panel → repeat the same requests with the **session closed**; if it returns 200 there is unauthorised access |
| **Page texts** | Were the privacy notice, cookie policy and terms of use pages published, are they reachable from the menu, does the language version really exist (in a multilingual project) |
| **Cross-border transfer** | The target country/IP in the network requests; from the provider's data processing contract |
| **Browser console warnings** | Cookie warnings, CSP violations, mixed content messages |

---

## 10. Frequently Made KVKK Mistakes

| Mistake | Symptom | What is correct |
|---|---|---|
| **The template trap** | In the text but not on the site (or exactly the reverse) | The comparison is done **bidirectionally**; `Conflict` is written |
| **A single consent checkbox** | The notice and the consent are merged into one `✓` | Separate checkboxes; the consent must be withdrawable |
| **A service bound to a consent requirement** | "Tick this so we can send you your message" | Responding is not conditional on consent; marketing is separate |
| **A pre-ticked box** | `defaultChecked` | It starts from an empty box |
| **Code loaded before consent** | The banner exists but the `<script>` is at the very top | The consent decision comes before the tag |
| **A request even after rejection** | "Reject" only closes the banner | The preference is persistent + the request is blocked |
| **Only a cookie list** | The browser's cookie names are copied | Purpose, duration and provider for each cookie |
| **Cross-border hidden** | "Cloud hosting" | Country + legal basis are written |
| **Security: logs** | `console.log(formData)`, `logger.info(user)` | Personal data is never written; a correlation id is enough |
| **No rate limit / bot protection** | The form endpoint is open | Rate limit + captcha/honeypot |
| **Legal appearance** | The phrase "we are KVKK compliant", no legal review done | The closing paragraph of this reference is written verbatim |
| **The missing page "later"** | The policy page was postponed until after publication | Tier A-2 is a publication blocker |