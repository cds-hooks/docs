---
title: API Reference

language_tabs:
  - code

toc_footers:
  - <a href='https://github.com/tripit/slate'>Documentation Powered by Slate</a>

includes:
  - cds_services
  - prefetch
  - security
  - hook_catalog
  - community
  - examples

search: true
---

# Overview

This specification describes a
["hook"](http://en.wikipedia.org/wiki/Hooking)-based pattern for invoking
decision support from within a clinician's EHR workflow. The API supports:

 * Synchronous, workflow-triggered CDS calls returning information and suggestions
 * Launching a user-facing SMART app when CDS requires deeper interaction
 * Long-running, non-modal CDS sessions that observe EHR activity in progress

<aside class="notice">
The CDS Hooks API is still in active development and thus subject to change. We're currently working towards a 1.0 release and would love your feedback and proposed changes. Look at our <a href="http://github.com/cds-hooks/docs/issues">current issue list</a> and get involved!
</aside>

## How it works

User activity inside the EHR triggers **CDS hooks** in real-time.  For example:

* `patient-view` when opening a new patient record
* `medication-prescribe` on authoring a new prescription
* `order-review` on viewing pending orders for approval

When a triggering activity occurs, the EHR notifies each CDS service registered for the activity. These services must then provide near-real-time feedback about the triggering event. Each service gets basic details about the EHR
context (via the `context` parameter of the hook) plus whatever
service-specific data are required (via the `pre-fetch-template` parameter).

![CDS Hooks Overview](images/overview.png)

## CDS Cards

Each CDS service can return any number of **cards** in response to the hook.
Cards convey some combination of text (*information card*), alternative
suggestions (*suggestion card*), and links to apps or reference
materials (*app link card*). A user sees these cards — one or more of each type
— embedded in the EHR, and can interact with them as follows:

* *information card*: provides text for the user to read.

* *suggestion card*: provides a specific suggestion for which the EHR renders a button that the user can click to accept. Clicking automatically populates the suggested change into the EHR's UI.

* *app link card*: provides a link to an app (often a SMART app) where the user can supply details, step through a flowchart, or do anything else required to help reach an informed decision. When the user has finished, flow returns to the EHR. At that point, the **EHR re-triggers the initial CDS hook**. The re-triggering may result in different cards, and may also include **decisions** (see below).

## CDS Decisions

In addition to cards, a CDS service may also return **decisions** — but only
after a user has interacted with the service via an *app link card*.
Returning a decision allows the the CDS service to communicate the user's choices  to the EHR without displaying an additional card.  For
example, a user might launch a hypertension management app, and upon
returning to the EHR's prescription page she expects her new blood pressure
prescription to "just be there". By returning a decision *instead of a card*,
the CDS service achieves this expected behavior. (*Note:* To return a
decision after a user interaction, the CDS service must maintain state
associated with the request's `hookInstance`;
when the EHR invokes the hook for a second time with the same
`hookInstance`, the service can respond with decisions on as well as cards.)

# Try it!

You can try CDS Hooks in our test harness at **[http://sandbox.cds-hooks.org](http://sandbox.cds-hooks.org)**
