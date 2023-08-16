<!-- ![CDS Hooks Overview](../images/logo.png) -->

<p style="padding: 5px; border-radius: 5px; border: 2px solid maroon; background: #ffffe6; max-width: 790px" markdown="1">
<b>Continuous Improvement Build</b>
<br>
This is the continuous integration, community release of the CDS Hooks specification. All stable releases are available at [https://cds-hooks.hl7.org](https://cds-hooks.hl7.org).
</p>

### Overview

This specification describes a
["hook"](http://en.wikipedia.org/wiki/Hooking)-based pattern for invoking
decision support from within a clinician's workflow. The API supports:

 * Synchronous, workflow-triggered CDS calls returning information and suggestions
 * Launching a user-facing SMART app when CDS requires additional interaction

### CDS Hooks Anatomy

This specification describes a ["hook"](https://en.wikipedia.org/wiki/Hooking)-based pattern for invoking
decision support from within a clinician's workflow. The API supports:

 * Synchronous, workflow-triggered CDS calls returning information and suggestions
* Launching a web page to provide additional information to the user
* Launching a user-facing SMART app when CDS requires additional interaction

The main concepts of the specification are Services, CDS Clients, and Cards.

#### CDS Services
A _CDS Service_ is a service that provides recommendations and guidance through the RESTful APIs described by this specification. The primary APIs are [Discovery](#discovery), which allows a CDS Developer to publish the types of CDS Services it provides. The [Service](#calling-a-cds-service) API that CDS Clients use to request decision support. The  [Feedback](#feedback) API through which services learn the outcomes of their recommendations and guidance.

#### CDS Clients
A _CDS Client_ is an Electronic Health Record (EHR), or other clinical information system that uses decision support by calling CDS Services at specific points in the application's workflow called [_hooks_](hooks.html). Each hook defines the _hook context_ (contextual information available within the CDS Client and specific to the workflow) that is provided as part of the request. Each service advertises which hooks it supports and what [_prefetch data_](#providing-fhir-resources-to-a-cds-service) (information needed by the CDS Service to determine what decision support should be presented) it requires. In addition, CDS Clients typically provide the FHIR resource server location and associated authorization information as part of the request to enable services to request additional information.

#### Cards
Decision support is then returned to the CDS Client in the form of [_cards_](#cds-service-response), which the CDS Client MAY display to the end-user as part of their workflow. Cards may be informational, or they may provide suggestions that the user may accept or reject they may provide a [link](#link) to additional information or even launch a SMART app when additional user interaction is required.
