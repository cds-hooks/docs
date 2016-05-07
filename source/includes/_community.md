# Community

## Get Involved

There are several ways in which you can get involved with the CDS Hooks community.

- Ask a question and participate in discussions via the [CDS Hooks Google Group](https://groups.google.com/forum/#!forum/cds-hooks)
- Chat via [Zulip](https://zulip.org/) at <https://chat.fhir.org> in the *cds-hooks* stream
- Contribute to the [code and documentation on Github](https://github.com/cds-hooks)

## CDS Hooks Sprint Program

### Objectives

 * Promote creation of clinical-grade service integrations (EHRs + CDS Services)
 * Gain implementation experience with real-world systems
 * Refine the spec, balancing ease of use, flexibility, and stability
 * Drive toward pilot deployments with the ability to measure results

### Technical Objectives

1. Decide [expectations for `preFetch` behavior](https://github.com/cds-hooks/cds-hooks-wiki/issues/9)
    --> possibly define an open-source gateway to smooth over the difference

2. Determine an [approach to publishing metadata](https://github.com/cds-hooks/cds-hooks-wiki/issues/10) ("JSON snippets")

3. ~~Evaluate approaches to conveying inputs/outputs in ["simple" (i.e. normal) JSON](https://github.com/cds-hooks/cds-hooks-wiki/issues/11)~~

4. Determine an [approach to security (authentication/authorization)](https://github.com/cds-hooks/cds-hooks-wiki/issues/12)

 * CDS Service needs to authenticate the EHR --> OAuth interaction
 * EHR needs to authenticate the service --> simple bearer tokens

### Ways to help

##### Help build out core infrastructure
 1. [Write a service exposing Card fixtures for testing](https://github.com/cds-hooks/cds-hooks-wiki/issues/1)
 2. [Write a tutorial](https://github.com/cds-hooks/cds-hooks-wiki/issues/2)
 3. [Write a preFetch Proxy](https://github.com/cds-hooks/cds-hooks-wiki/issues/3)
 4. Write a set of test hook *calls*

##### Build your own components:
 1. CDS services
 2. EHR support

### Pilot Opportunities

 * BCH/Cerner building support for prescription hooks
 * Others?

## Create a CDS Hook

1. Listen at {{base}}/$cds-hook
2. Expose metadata at {{base}}/$cds-hook-metadata
3. Load into test harness and try it

## Sprint 1 (two weeks)

#### Infrastructure:

 * Establish a [repository of "test cards"](https://github.com/cds-hooks/cds-hooks-wiki/issues/4)
 * Stand up a ["test card service"](https://github.com/cds-hooks/cds-hooks-wiki/issues/5) to host them (fixtures)
 * [Build a "CDS invoker" that simulates an EHR](https://github.com/cds-hooks/cds-hooks-wiki/issues/6), invoking external services with fixed payloads 

#### EHR participants:

 * Call a CDS Service for `patient-view` activity
 * Display text cards inline

#### CDS Service participants:

 * Build a CDS Service responding to `patient-view` activity
 * "Information cards" only (plain text), for a start

## Sprint 2 (two weeks)

#### Infrastructure:

 * Build a ["card validator"](https://github.com/cds-hooks/cds-hooks-wiki/issues/7) that provides rapid, automated feedback if cards have errors
 * [Integrate "card validator" into "test EHR"](https://github.com/cds-hooks/cds-hooks-wiki/issues/8)

#### EHR participants:

 * Display `app link` cards, and `information` cards with markdown, inline
 * Ensure that FHIR API endpoint is included in service calls

#### CDS Service participants:

 * Return `app link` cards and `information` card with markdown, inline

## Sprint 3 (two weeks)

#### Infrastructure:

 * Build a ["preFetch proxy"](https://github.com/cds-hooks/cds-hooks-wiki/issues/3) to automatically produce preFetch data when unavailable from EHR

 * Write a [CDS Service developer's tutorial](https://github.com/cds-hooks/cds-hooks-wiki/issues/2)

#### EHR participants:

 * Build support for `preFetch` data ?

#### CDS Service participants:

 * Set up automated testing with the CDS Invoker
