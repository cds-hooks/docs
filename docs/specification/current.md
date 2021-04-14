![CDS Hooks Overview](../images/logo.png)

!!! info "Current (draft)"
    This is the continuous integration, community release of the CDS Hooks specification. All stable releases are available at [https://cds-hooks.hl7.org](https://cds-hooks.hl7.org).

## Overview

The CDS Hooks specification describes the RESTful APIs and interactions to integrate Clinical Decision Support (CDS) between CDS Clients (typically Electronic Health Record Systems (EHRs) or other health information systems) and CDS Services. All data exchanged through the RESTful APIs MUST be sent and received as [JSON](https://tools.ietf.org/html/rfc8259) (JavaScript Object Notation) structures, and MUST be transmitted over channels secured using the Hypertext Transfer Protocol (HTTP) over Transport Layer Security (TLS), also known as HTTPS and defined in [RFC2818](https://tools.ietf.org/html/rfc2818).

Unless otherwise specified, JSON attributes SHALL NOT be null. If a JSON attribute is defined with an optionality of OPTIONAL, but does not have a value, implementers MUST omit it. For instance, OPTIONAL JSON string and array attributes should be omitted rather than having a null or empty value. Similarly, JSON objects SHALL NOT be empty.

Unless otherwise specified, JSON string or URL (Uniform Resource Locator) attributes that have an optionality of REQUIRED MAY NOT have empty values (those without any characters or just whitespace characters).

### Conformance Language
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this specification are to be interpreted as described in [RFC2119](https://tools.ietf.org/html/rfc2119).

## CDS Hooks Anatomy

This specification describes a ["hook"](https://en.wikipedia.org/wiki/Hooking)-based pattern for invoking
decision support from within a clinician's workflow. The API supports:

 * Synchronous, workflow-triggered CDS calls returning information and suggestions
 * Launching a user-facing SMART app when CDS requires additional interaction

The basic components of CDS Hooks are:

### CDS Services
In CDS Hooks, a _CDS Service_ is a service that provides patient-specific recommendations and guidance through RESTful APIs as described by this specification. The primary APIs are [Discovery](#discovery), which allows a CDS Developer to publish the types of CDS Services it provides, and the [Service](#calling-a-cds-service) endpoint that CDS Clients use to request decision support.

### CDS Clients
A _CDS Client_ is an electronic health record, or other clinical information system that consumes decision support by calling CDS Services at specific points in the application's workflow called [_hooks_](#hooks). Each hook defines the _hook context_, contextual information available within the client and specific to the workflow and provided as part of the request. Each service advertises which hooks it supports and what [_prefetch data_](#providing-fhir-resources-to-a-cds-service) (information needed by the CDS Service to determine what decision support should be presented) it requires. In addition, CDS Clients MAY provide an authorization and FHIR resource server as part of the request to enable services to request additional information.

### Cards
Decision support is then returned to the CDS Client in the form of [_cards_](#cds-service-response), which the client MAY display to the end-user as part of their workflow. Cards may be informational, or they may provide suggestions that the user may accept or reject, or they may provide a [link](#link) to additional information or even launch a SMART app when additional user interaction is required.

## Discovery

Developers of CDS Services SHALL provide a stable endpoint for allowing CDS Clients to discover available CDS Services, including information such as a description of the CDS Service, when it should be invoked, and any data that is requested to be prefetched.

A CDS Service provider SHALL expose its Discovery endpoint at"

```shell
{baseURL}/cds-services
```
### HTTP Request

The discovery endpoint SHALL always be available at `{baseUrl}/cds-services`. For example, if the `baseUrl` is https://example.com, the CDS Client MAY invoke:

`GET https://example.com/cds-services`

### Response

The response to the discovery endpoint SHALL be an object containing a list of CDS Services.

Field | Description
----- | ---------
`services` | *array*. An array of **CDS Services**.

Each CDS Service SHALL be described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | ---------
`hook`| REQUIRED | *string* | The hook this service should be invoked on. See [Hooks](#hooks).
`title`| RECOMMENDED | *string* | The human-friendly name of this service.
<nobr>`description`</nobr>| REQUIRED | *string* | The description of this service.
`id` | REQUIRED | *string* | The {id} portion of the URL to this service which is available at<br />`{baseUrl}/cds-services/{id}`
`prefetch` | OPTIONAL | *object* | An object containing key/value pairs of FHIR queries that this service is requesting that the CDS Client prefetch and provide on each service call. The key is a *string* that describes the type of data being requested and the value is a *string* representing the FHIR query.<br />See [Prefetch Template](#prefetch-template).

### HTTP Status Codes

Code | Description
---- | -----------
`200 OK` | A successful response.

CDS Services MAY return other HTTP statuses, specifically 4xx and 5xx HTTP error codes.

### Discovery Example

```shell
curl "https://example.com/cds-services"
```

> The above command returns JSON structured like this:

```json
{
  "services": [
    {
      "hook": "patient-view",
      "title": "Static CDS Service Example",
      "description": "An example of a CDS Service that returns a static set of cards",
      "id": "static-patient-greeter",
      "prefetch": {
        "patientToGreet": "Patient/{{context.patientId}}"
      }
    },
    {
      "hook": "order-select",
      "title": "Order Echo CDS Service",
      "description": "An example of a CDS Service that simply echos the order(s) being placed",
      "id": "order-echo",
      "prefetch": {
        "patient": "Patient/{{context.patientId}}",
        "medications": "MedicationRequest?patient={{context.patientId}}"
      }
    }
  ]
}
```


## Calling a CDS Service

### HTTP Request

A CDS Client SHALL call a CDS Service by `POST`ing a JSON document to the service as described in this section. The CDS Service endpoint can be constructed from the CDS Service base URL and an individual service id as `{baseUrl}/cds-services/{service.id}`. The request SHALL include a JSON `POST` body with the following input fields:

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`hook` | REQUIRED | *string* | The hook that triggered this CDS Service call. See [Hooks](#hooks).
<nobr>`hookInstance`</nobr> | REQUIRED | *string* | A universally unique identifier (UUID) for this particular hook call (see more information below).
`fhirServer` | OPTIONAL | *URL* | The base URL of the CDS Client's [FHIR](https://www.hl7.org/fhir/) server. If fhirAuthorization is provided, this field is REQUIRED.  The scheme should be `https`
`fhirAuthorization` | OPTIONAL | *object* | A structure holding an [OAuth 2.0][OAuth 2.0] bearer access token granting the CDS Service access to FHIR resources, along with supplemental information relating to the token. See the [FHIR Resource Access](#fhir-resource-access) section for more information.
`context` | REQUIRED | *object* | Hook-specific contextual data that the CDS service will need.<br />For example, with the `patient-view` hook this will include the FHIR identifier of the [Patient](https://www.hl7.org/fhir/patient.html) being viewed.  For details, see the Hooks specification page.
`prefetch` | OPTIONAL | *object* | The FHIR data that was prefetched by the CDS Client (see more information below).

#### hookInstance

While working in the CDS Client, a user can perform multiple actions in series or in parallel. For example, a clinician might prescribe two drugs in a row; each prescription action would be assigned a unique `hookInstance`. This allows a CDS Service to uniquely identify each hook invocation.

Note: the `hookInstance` is globally unique and should contain enough entropy to be un-guessable.

### Example

```
curl
  -X POST \
  -H 'Content-type: application/json' \
  --data @hook-details-see-example-below
  "https://example.com/cds-services/static-patient-greeter"
```

```json
{
   "hookInstance" : "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
   "fhirServer" : "http://hooks.smarthealthit.org:9080",
   "hook" : "patient-view",
   "fhirAuthorization" : {
     "access_token" : "some-opaque-fhir-access-token",
     "token_type" : "Bearer",
     "expires_in" : 300,
     "scope" : "patient/Patient.read patient/Observation.read",
     "subject" : "cds-service4"
   },
   "context" : {
       "userId" : "Practitioner/example",
       "patientId" : "1288992",
       "encounterId" : "89284"
   },
   "prefetch" : {
      "patientToGreet" : {
         "resourceType" : "Patient",
         "gender" : "male",
         "birthDate" : "1925-12-23",
         "id" : "1288992",
         "active" : true
      }
   }
}
```


## Providing FHIR Resources to a CDS Service

Each CDS Service will require specific FHIR resources in order to compute the recommendations the CDS Client requests. If real-world performance were no issue, an CDS Client could launch a CDS Service passing only context data (such as the current user and patient ids), and the CDS Service could then request authorization for FHIR resources as they were needed, and then retrieve the resources from the CDS Client's FHIR server.  Given that CDS Services SHOULD respond quickly (on the order of 500 ms.), this specification defines a process to allow a CDS Service to request and obtain FHIR resources efficiently.

Two optional methods are provided.  First, FHIR resources MAY be obtained by passing "prefetched" data from the CDS Client to the CDS Service in the service call.  FHIR resources requested in the CDS Service description are passed as key-value pairs, with each key matching a key described in the CDS Service description, and each value being a FHIR resource. Note that in the case of searches, this resource may be a [`searchset`](http://hl7.org/fhir/bundle.html#searchset) Bundle. If data are to be prefetched, the CDS Service registers a set of "prefetch templates" with the CDS Client, as described in the [Prefetch Template](#prefetch-template) section below.

The second method enables the CDS Service to retrieve FHIR resources for itself, but to do so more efficiently than if it were required to request and obtain its own authorization.  If the CDS Client decides to have the CDS Service fetch its own FHIR resources, the CDS Client obtains and passes directly to the CDS Service a bearer token issued for the CDS Service's use in executing FHIR API calls against the CDS Client's FHIR server to obtain the required resources.  Some CDS Clients MAY pass prefetched data, along with a bearer token for the CDS Service to use if additional resources are required.  Each CDS Client SHOULD decide which approach, or combination, is preferred, based on performance considerations and assessment of attendant security and safety risks. For more detail, see the [FHIR Resource Access](#fhir-resource-access) section below.

Similarly, each CDS Client will decide what FHIR resources to authorize and to prefetch, based on the CDS Service description's "prefetch" request and on the provider's assessment of the "minimum necessary."  The CDS Client provider and the CDS Service provider will negotiate the set of FHIR resources to be provided, and how these data will be provided, as part of their service agreement.

### Prefetch Template

A _prefetch template_ is a FHIR [`read`](http://hl7.org/fhir/http.html#read) or [`search`](http://hl7.org/fhir/http.html#search) request that describes relevant data needed by the CDS Service. For example, the following is a prefetch template for hemoglobin A1c observations:

```
Observation?patient={{context.patientId}}&code=4548-4&_count=1&sort:desc=date
```

To allow for prefetch templates that are dependent on the workflow context, prefetch templates may include references to context using [_prefetch tokens_](#prefetch-tokens). In the above example, `{{context.patientId}}` is a prefetch token.

The `prefetch` field of a CDS Service description defines the set of prefetch templates for that service, providing a _prefetch key_ for each one that is used to identify the prefetch data in the CDS request. For example:

```json
{
  "prefetch": {
    "hemoglobin-a1c": "Observation?patient={{context.patientId}}&code=4548-4&_count=1&sort:desc=date"
  }
}
```

In this `prefetch`, `hemoglobin-a1c` is the prefetch key for this prefetch template. For a complete worked example, see [below](#example-prefetch-templates).

A CDS Client MAY choose to honor some or all of the desired prefetch templates, and is free to choose the most appropriate source for these data. For example:

- The CDS Client MAY have some of the desired prefetched data already in memory, thereby removing the need for any network call
- The CDS Client MAY compute an efficient set of prefetch templates from multiple CDS Services, thereby reducing the number of calls to a minimum
- The CDS Client MAY satisfy some of the desired prefetched templates via some internal service or even its own FHIR server.

The CDS Client SHALL deny access to the requested resource if it is outside the user's authorized scope.

As part of preparing the request, a CDS Client processes each prefetch template it intends to satisfy by replacing the prefetch tokens in the prefetch template to construct a relative FHIR request URL. This specification is not prescriptive about how this request is actually processed. The relative URL may be appended to the base URL for the CDS Client's FHIR server and directly invoked, or the CDS Client may use internal infrastructure to satisfy the request in the same way that invoking against the FHIR server would.

Regardless of how the CDS Client satisfies the prefetch templates (if at all), the prefetched data given to the CDS Service MUST be equivalent to the data the CDS Service would receive if it were making its own call to the CDS Client's FHIR server using the parameterized prefetch template.

> Note that this means that CDS services will receive only the information they have requested and are authorized to receive. Prefetch data for other services registered to the same hook MUST NOT be provided. In other words, services SHALL only receive the data they requested in their prefetch.

The resulting response, which MUST be rendered in a single page — no "next page" links allowed — is passed along to the CDS Service using the `prefetch` parameter (see [below](#example-prefetch-templates) for a complete example).

> Note that the reason prefetch results are not allowed to include next page links is that if the prefetched data contains just a single page of data, the CDS Service has no means to retrieve the subsequent pages of data. Consider, for example, a CDS Hooks implementation that does not expose a FHIR server.

The CDS Client MUST NOT send any prefetch template key that it chooses not to satisfy. Similarly, if the CDS Client encounters an error while prefetching any data, the prefetch template key MUST NOT be sent to the CDS Service. If the CDS Client has no data to populate a template prefetch key, the prefetch template key MUST have a value of __null__. Note that the __null__ result is used rather than a bundle with zero entries to account for the possibility that the prefetch url is a single-resource request.

It is the CDS Service's responsibility to check prefetched data against its template to determine what requests were satisfied (if any) and to programmatically retrieve any additional necessary data. If the CDS Service is unable to obtain required data because it cannot access the FHIR server and the request did not contain the necessary prefetch keys, the service SHALL respond with an HTTP 412 Precondition Failed status code.

#### Prefetch tokens

A prefetch token is a placeholder in a prefetch template that is replaced by a value from the hook's context to construct the FHIR URL used to request the prefetch data.

Prefetch tokens MUST be delimited by `{{` and `}}`, and MUST contain only the qualified path to a hook context field.

Individual hooks specify which of their `context` fields can be used as prefetch tokens. Only root-level fields with a primitive value within the `context` object SHALL be used as prefetch tokens. For example, `{{context.medication.id}}` is not a valid prefetch token because it attempts to access the `id` field of the `medication` field. Hook creators MUST document which fields in the context are supported as tokens. If a context field can be tokenized, the value of the context field MUST be a JSON primitive data type that can placed into a FHIR query (i.e. a string, a number, or a boolean).

#### Prefetch query restrictions

To reduce the implementation burden on CDS Clients that support CDS Services, this specification RECOMMENDS that prefetch queries only use a subset of the full functionality available in the FHIR specification. Valid prefetch templates SHOULD only make use of:

* _instance_ level [read](https://www.hl7.org/fhir/http.html#read) interactions (for resources with known ids such as `Patient` and `Practitioner`)
* _type_ level [search](https://www.hl7.org/fhir/http.html#search) interactions
* Patient references (e.g. `patient={{context.patientId}}`)
* _token_ search parameters using equality (e.g. `code=4548-4`) and optionally the `:in` modifier (no other modifiers for token parameters)
* _date_ search parameters on `date`, `dateTime`, `instant`, or `Period` types only, and using only the prefixes `eq`, `lt`, `gt`, `ge`, `le`
* the `_count` parameter to limit the number of results returned
* the `_sort` parameter to allow for _most recent_ and _first_ queries

#### Example prefetch token

Often a prefetch template builds on the contextual data associated with the hook. For example, a particular CDS Service might recommend guidance based on a patient's conditions when the chart is opened. The FHIR query to retrieve these conditions might be `Condition?patient=123`. In order to express this as a prefetch template, the CDS Service must express the FHIR identifier of the patient as a token so that the CDS Client can replace the token with the appropriate value. When context fields are used as tokens, their token name MUST be `context.name-of-the-field`. For example, given a context like:

```json
"context" : {
  "patientId": "123"
}
```

The token name would be `{{context.patientId}}`. Again using our above conditions example, the complete prefetch template would be `Condition?patient={{context.patientId}}`.

Only the first level fields in context may be considered for tokens. 

For example, given the following context that contains amongst other things, a Patient FHIR resource:

```json
"context" : {
  "encounterId": "456",
  "patient": {
    "resourceType": "Patient",
    "id": "123",
    "active": true,
    "name": [
      {
        "use": "official",
        "family": "Watts",
        "given": [
          "Wade"
        ]
      }
    ],
    "gender": "male",
    "birthDate": "2024-08-12"
  }
}
```

Only the `encounterId` field in this example is eligible to be a prefetch token as it is a first level field and the datatype (string) can be placed into the FHIR query. The Patient.id value in the context is not eligible to be a prefetch token because it is not a first level field. If the hook creator intends for the Patient.id value to be available as a prefetch token, it must be made available as a first level field. Using the aforementioned example, we simply add a new `patientId` field:

```json
"context" : {
  "patientId": "123",
  "encounterId": "456",
  "patient": {
    "resourceType": "Patient",
    "id": "123",
    "active": true,
    "name": [
      {
        "use": "official",
        "family": "Watts",
        "given": [
          "Wade"
        ]
      }
    ],
    "gender": "male",
    "birthDate": "2024-08-12"
  }
}
```

#### Example prefetch templates

```json
{
  "prefetch": {
    "patient": "Patient/{{context.patientId}}",
    "hemoglobin-a1c": "Observation?patient={{context.patientId}}&code=4548-4&_count=1&sort:desc=date",
    "user": "{{context.userId}}"
  }
}
```

Here is an example prefetch field from a CDS Service discovery endpoint. The
goal is to know, at call time:

| Key | Description |
| --- | ----------- |
| `patient` | Patient demographics. |
| `hemoglobin-a1c` | Most recent Hemoglobin A1c reading for this patient. |
| `user` | Information on the current user.

#### Example prefetch data

```json
{
  "prefetch": {
    "patient":{
      "resourceType": "Patient",
      "gender": "male",
      "birthDate": "1974-12-25",
      "...": "<snipped for brevity>"
    },
    "hemoglobin-a1c": {
      "resourceType": "Bundle",
      "type": "searchset",
      "entry": [{
        "resource": {
        "resourceType": "Observation",
        "code": {
          "coding": [{
            "system": "http://loinc.org",
            "code": "4548-4",
            "display": "Hemoglobin A1c"
            }]
          },
          "...": "<snipped for brevity>"
        }
      }]
    }
  }
}
```

The CDS Hooks request is augmented to include two prefetch values, where the dictionary
keys match the request keys (`patient` and `hemoglobin-a1c` in this case).

Note that the missing `user` key indicates that either the CDS Client has decided not to satisfy this particular prefetch template or it was not able to retrieve this prefetched data. The CDS Service is responsible for retrieving the FHIR resource representing the user from the FHIR server (if required).

### FHIR Resource Access

If the CDS Client provides both `fhirServer` and `fhirAuthorization` request parameters, the CDS Service MAY use the FHIR server to obtain any FHIR resources it requires beyond those provided by the CDS Client as prefetched data. This is similar to the approach used by SMART on FHIR wherein the SMART app requests and ultimately obtains an access token from the CDS Client's Authorization server using the SMART launch workflow, as described in [SMART App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch/1.0.0/).

Like SMART on FHIR, CDS Hooks requires that clients present a valid access token to the FHIR server with each API call. Thus, a CDS Service MUST be able to obtain an access token before communicating with the CDS Client's FHIR resource server. While CDS Hooks shares the underlying technical framework and standards as SMART on FHIR, the CDS Hooks workflow MUST accommodate the automated, low-latency delivery of an access token to the CDS service.

With CDS Hooks, if the CDS Client wants to provide the CDS Service direct access to FHIR resources, the CDS Client creates an access token prior to invoking the CDS Service, passing this token to the CDS Service as part of the service call. This approach remains compatible with [OAuth 2.0's][OAuth 2.0] bearer token protocol while minimizing the number of HTTPS round-trips and the service invocation latency. The CDS Client remains in control of creating an access token that is associated with the specific CDS Service, user, and context of the invocation.  As the CDS Service executes on behalf of a user, the data to which the CDS Service is given access by the CDS Client MUST be limited to the same restrictions and authorizations afforded the current user. As such, the access token SHALL be scoped to:

- The CDS Service being invoked
- The current user

#### Passing the Access Token to the CDS Service

The access token is specified in the CDS Service request via the `fhirAuthorization` request parameter. This parameter is an object that contains both the access token as well as other related information as specified below.  If the CDS Client chooses not to pass along an access token, the `fhirAuthorization` parameter is omitted.

Field | Optionality | Type | Description
----- | ----- | ----- | -----------
`access_token` | REQUIRED | *string* | This is the [OAuth 2.0][OAuth 2.0] access token that provides access to the FHIR server.
`token_type`   | REQUIRED | *string* | Fixed value: `Bearer`
`expires_in`   | REQUIRED | *integer* | The lifetime in seconds of the access token.
`scope`        | REQUIRED | *string* | The scopes the access token grants the CDS Service.
`subject` | REQUIRED | *string* | The [OAuth 2.0][OAuth 2.0] client identifier of the CDS Service, as registered with the CDS Client's authorization server.

The scopes granted to the CDS Service via the `scope` field are defined by the [SMART on FHIR specification](http://hl7.org/fhir/smart-app-launch/1.0.0/scopes-and-launch-context/).

The `expires_in` value is established by the authorization server and SHOULD BE very short lived, as the access token MUST be treated as a transient value by the CDS Service. CDS Clients MAY revoke an issued access token upon the completion of the CDS Hooks request/response to limit the validity period of the token. 

Below is an example `fhirAuthorization` parameter:

```json
{
  "fhirAuthorization" : {
    "access_token" : "some-opaque-fhir-access-token",
    "token_type" : "Bearer",
    "expires_in" : 300,
    "scope" : "patient/Patient.read patient/Observation.read",
    "subject" : "cds-service4"
  }
}
```

## CDS Service Response

For successful responses, CDS Services SHALL respond with a 200 HTTP response with an object containing a `cards` array and optionally a `systemActions` array as described below.

Each card contains decision support from the CDS Service. Generally speaking, cards are intended for display to an end user. The data format of a card defines a very minimal set of required attributes with several more optional attributes to suit a variety of use cases. For instance, narrative informational decision support, actionable suggestions to modify data, and links to SMART apps.

> Note that because the CDS client may be invoking multiple services from the same hook, there may be multiple responses related to the same information. This specification does not address these scenarios specifically; both CDS Services and CDS Clients should consider the implications of multiple CDS Services in their integrations.

### HTTP Status Codes

Code | Description
---- | -----------
`200 OK` | A successful response.
`412 Precondition Failed` | The CDS Service is unable to retrieve the necessary FHIR data to execute its decision support, either through a prefetch request or directly calling the FHIR server.

CDS Services MAY return other HTTP statuses, specifically 4xx and 5xx HTTP error codes.

### HTTP Response

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`cards` | REQUIRED | *array* | An array of **Cards**. Cards can provide a combination of information (for reading), suggested actions (to be applied if a user selects them), and links (to launch an app if the user selects them). The CDS Client decides how to display cards, but this specification recommends displaying suggestions using buttons, and links using underlined text.
`systemActions` | OPTIONAL | *array* |  An array of actions that the CDS Service proposes to auto-apply. Each action follows the schema of a [card-based `suggestion.action`](#action). The CDS Client decides whether to auto-apply actions.

If your CDS Service has no decision support for the user, your service should return a 200 HTTP response with an empty array of cards.

> Response when no decision support is necessary for the user

```json
{
  "cards": []
}
```

### Card Attributes

Each **Card** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`uuid` | OPTIONAL | *string* | Unique identifier of the card.  MAY be used for auditing and logging cards and SHALL be included in any subsequent calls to the CDS service's feedback endpoint.
`summary` | REQUIRED | *string* | One-sentence, <140-character summary message for display to the user inside of this card.
`detail` | OPTIONAL | *string* | Optional detailed information to display; if provided MUST be represented in [(GitHub Flavored) Markdown](https://github.github.com/gfm/). (For non-urgent cards, the CDS Client MAY hide these details until the user clicks a link like "view more details...").
`indicator` | REQUIRED | *string* | Urgency/importance of what this card conveys. Allowed values, in order of increasing urgency, are: `info`, `warning`, `critical`. The CDS Client MAY use this field to help make UI display decisions such as sort order or coloring.
`source` | REQUIRED | *object* | Grouping structure for the **Source** of the information displayed on this card. The source should be the primary source of guidance for the decision support the card represents.
<nobr>`suggestions`</nobr> | OPTIONAL | *array* of **Suggestions** | Allows a service to suggest a set of changes in the context of the current activity (e.g.  changing the dose of a medication currently being prescribed, for the `order-sign` activity). If suggestions are present, `selectionBehavior` MUST also be provided.
`selectionBehavior` | OPTIONAL | *string* | Describes the intended selection behavior of the suggestions in the card. Allowed values are: `at-most-one`, indicating that the user may choose none or at most one of the suggestions;`any`, indicating that the end user may choose any number of suggestions including none of them and all of them. CDS Clients that do not understand the value MUST treat the card as an error.
`overrideReasons` | OPTIONAL | *array* of **Coding** | Override reasons can be selected by the end user when overriding a card without taking the suggested recommendations. The CDS service MAY return a list of override reasons to the CDS client. The CDS client SHOULD present these reasons to the clinician when they dismiss a card. A CDS client MAY augment the override reasons presented to the user with its own reasons.
`links` | OPTIONAL | *array* of **Links** | Allows a service to suggest a link to an app that the user might want to run for additional information or to help guide a decision.

#### Source

The **Source** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
<nobr>`label`</nobr>| REQUIRED | *string* | A short, human-readable label to display for the source of the information displayed on this card. If a `url` is also specified, this MAY be the text for the hyperlink.
`url` | OPTIONAL | *URL* | An optional absolute URL to load (via `GET`, in a browser context) when a user clicks on this link to learn more about the organization or data set that provided the information on this card. Note that this URL should not be used to supply a context-specific "drill-down" view of the information on this card. For that, use `link.url` instead.
`icon` | OPTIONAL | *URL* | An absolute URL to an icon for the source of this card. The icon returned by this URL SHOULD be a 100x100 pixel PNG image without any transparent regions.
`topic` | OPTIONAL | **Coding** | A *topic* describes the content of the card by providing a high-level categorization that can be useful for filtering, searching or ordered display of related cards in the CDS client's UI. This specification does not prescribe a standard set of topics.

Below is an example `source` parameter:

```json
{
  "source" : {
    "label" : "Zika Virus Management",
    "url" : "https://example.com/cdc-zika-virus-mgmt",
    "icon" : "https://example.com/cdc-zika-virus-mgmt/100.png",
    "topic" : {
      "system": "http://example.org/cds-services/fhir/CodeSystem/topics",
      "code": "12345",
      "display": "Mosquito born virus"
    }
  }
}
```

#### Suggestion

Each **Suggestion** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`label` | REQUIRED | *string* | Human-readable label to display for this suggestion (e.g. the CDS Client might render this as the text on a button tied to this suggestion).
`uuid` | OPTIONAL | *string* | Unique identifier, used for auditing and logging suggestions.
`isRecommended` | OPTIONAL | *boolean* | When there are multiple suggestions, allows a service to indicate that a specific suggestion is recommended from all the available suggestions on the card. CDS Hooks clients may choose to influence their UI based on this value, such as pre-selecting, or highlighting recommended suggestions. Multiple suggestions MAY be recommended, if `card.selectionBehavior` is `any`.
`actions` | OPTIONAL | *array* | Array of objects, each defining a suggested action. Within a suggestion, all actions are logically AND'd together, such that a user selecting a suggestion selects all of the actions within it.

##### Action

Each **Action** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`type` |  REQUIRED | *string* | The type of action being performed. Allowed values are: `create`, `update`, `delete`.
`description` | REQUIRED | *string* | Human-readable description of the suggested action MAY be presented to the end-user.
`resource` | CONDITIONAL | *object* | A FHIR resource. When the `type` attribute is `create`, the `resource` attribute SHALL contain a new FHIR resource to be created.  For `update`, this holds the updated resource in its entirety and not just the changed fields. Use of this field to communicate a string of a FHIR id for delete suggestions is DEPRECATED and `resourceId` SHOULD be used instead.
`resourceId` | CONDITIONAL | *string* | A relative reference to the relevant resource. SHOULD be provided when the `type` attribute is `delete`. 

The following example illustrates a create action:

```json
{
	"type": "create",
	"description": "Create a prescription for Acetaminophen 250 MG",
	"resource": {
		"resourceType": "MedicationRequest",
		"id": "medrx001",
		"...": "<snipped for brevity>"
	}
}
```

The following example illustrates an update action:

```json
{
	"type": "update",
	"description": "Update the order to record the appropriateness score",
	"resource": {
		"resourceType": "ServiceRequest",
		"id": "procedure-request-1",
		"...": "<snipped for brevity>"
	}
}
```

The following example illustrates a delete action:

```json
{
	"type": "delete",
	"description": "Remove the inappropriate order",
	"resourceId": "ServiceRequest/procedure-request-1"
}
```


#### Reasons for rejecting a card

**overrideReasons** is an array of **Coding** that captures a codified set of reasons an end user may select from as the rejection reason when rejecting the advice presented in the card. When using the coding object representing a reason, implementations are required to only respect the *code* property. However, they may consume other properties for a better end user experience, such as presenting a human readable text in the *display* property instead of the *code* itself to the end user.

This specification does not prescribe a standard set of override reasons; implementers are encouraged to submit suggestions for standardization.

```json
{
    "overrideReasons": [{
        "code": "reason-code-provided-by-service",
        "system": "http://example.org/cds-services/fhir/CodeSystem/override-reasons",
        "display": "Patient refused"
    }, {
        "code": "12354",
        "system": "http://example.org/cds-services/fhir/CodeSystem/override-reasons",
        "display": "Contraindicated"
    }]
}
```

#### Link

Each **Link** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
<nobr>`label`</nobr>| REQUIRED | *string* | Human-readable label to display for this link (e.g. the CDS Client might render this as the underlined text of a clickable link).
`url` | REQUIRED | *URL* | URL to load (via `GET`, in a browser context) when a user clicks on this link. Note that this MAY be a "deep link" with context embedded in path segments, query parameters, or a hash.
`type` | REQUIRED | *string* | The type of the given URL. There are two possible values for this field. A type of `absolute` indicates that the URL is absolute and should be treated as-is. A type of `smart` indicates that the URL is a SMART app launch URL and the CDS Client should ensure the SMART app launch URL is populated with the appropriate SMART launch parameters.
`appContext` | OPTIONAL | *string* |  An optional field that allows the CDS Service to share information from the CDS card with a subsequently launched SMART app. The `appContext` field should only be valued if the link type is `smart` and is not valid for `absolute` links. The `appContext` field and value will be sent to the SMART app as part of the [OAuth 2.0][OAuth 2.0] access token response, alongside the other [SMART launch parameters](http://hl7.org/fhir/smart-app-launch/1.0.0/scopes-and-launch-context/#launch-context-arrives-with-your-access_token) when the SMART app is launched. Note that `appContext` could be escaped JSON, base64 encoded XML, or even a simple string, so long as the SMART app can recognize it.


### System Action
A `systemAction` is the same **Action** which may be returned in a suggestion, but is instead returned alongside the array of cards. A `systemAction` is not presented to the user within a card, but rather may be auto-applied without user intervention.

```json
{
	"cards": [],
	"systemActions": [{
		"type": "update",
		"resource": {
			"resourceType": "ServiceRequest",
			"id": "example-MRI-59879846",
                        "...": "<snipped for brevity"

		}
	}]
}
```

### Example

> Example response

```json
{
  "cards": [
    {
      "uuid": "4e0a3a1e-3283-4575-ab82-028d55fe2719",
      "summary": "Example Card",
      "indicator": "info",
      "detail": "This is an example card.",
      "source": {
        "label": "Static CDS Service Example",
        "url": "https://example.com",
        "icon": "https://example.com/img/icon-100px.png"
      },
      "links": [
        {
          "label": "Google",
          "url": "https://google.com",
          "type": "absolute"
        },
        {
          "label": "Github",
          "url": "https://github.com",
          "type": "absolute"
        },
        {
          "label": "SMART Example App",
          "url": "https://smart.example.com/launch",
          "type": "smart",
          "appContext": "{\"session\":3456356,\"settings\":{\"module\":4235}}"
        }
      ]
    },
    {
      "summary": "Another card",
      "indicator": "warning",
      "source": {
        "label": "Static CDS Service Example"
      }
    }
  ]
}
```

## Feedback

Once a CDS Hooks service responds to a hook by returning a card, the service has no further interaction with the CDS client. The acceptance of a suggestion or rejection of a card is valuable information to enable a service to improve its behavior towards the goal of the end-user having a positive and meaningful experience with the CDS. A feedback endpoint enables suggestion tracking & analytics.

Upon receiving a card, a user may accept its suggestions, ignore it entirely, or dismiss it with or without an override reason. Note that while one or more suggestions can be accepted, an entire card is either ignored or overridden.

Typically, an end user may only accept (a suggestion), or override a card once; however, a card once ignored could later be acted upon. CDS Hooks does not specify the UI behavior of CDS clients, including the persistence of cards. CDS clients should faithfully report each of these distinct end-user interactions as feedback.

Each **Feedback** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`card` | REQUIRED | *string* | The `card.uuid` from the CDS Hooks response. Uniquely identifies the card.
`outcome` | REQUIRED | *string* | A value of `accepted` or `overridden`.
`acceptedSuggestions` | CONDITIONAL | *array* | An array of json objects identifying one or more of the user's **AcceptedSuggestion**s. Required for `accepted` outcomes.
`overrideReason` | OPTIONAL | **OverrideReason** | A json object capturing the override reason as a **Coding** as well as any comments entered by the user.
`outcomeTimestamp` | REQUIRED | *string* | ISO timestamp in UTC when action was taken on card.

### Suggestion accepted

The CDS client can inform the service when one or more suggestions were accepted by POSTing a simple json object. The CDS client authenticates to the CDS service as described in [Trusting CDS Clients](#trusting-cds-clients).

Upon the user accepting a suggestion (perhaps when she clicks a displayed label (e.g., button) from a "suggestion" card), the CDS client informs the service by posting the card and suggestion `uuid`s to the CDS Service's feedback endpoint with an outcome of `accepted`.

To enable a positive clinical experience, the feedback endpoint may be called for multiple hook instances or multiple cards at the same time or even multiple times for a card or suggestion. Depending upon the UI and workflow of the CDS client, a CDS Service may receive feedback for the same card instance multiple times.

Each **AcceptedSuggestion** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`id` | REQUIRED | *string* | The `card.suggestion.uuid` from the CDS Hooks response. Uniquely identifies the suggestion that was accepted.

```json
POST {baseUrl}/cds-services/{serviceId}/feedback

{
   "feedback":[
      {
         "card":"4e0a3a1e-3283-4575-ab82-028d55fe2719",
         "outcome":"accepted",
         "acceptedSuggestions": [ { "id" : "e56e1945-20b3-4393-8503-a1a20fd73152" } ],
         "outcomeTimestamp": "2020-12-11T00:00:00Z"
      }
   ]
}
```

If either the card or the suggestion has no `uuid`, the CDS client does not send a notification.

### Card ignored

If the end-user doesn't interact with the CDS Service's card at all, the card is *ignored*. In this case, the CDS Client does not inform the CDS Service of the rejected guidance. Even with a `card.uuid`, a `suggestion.uuid`, and an available feedback service, the service is not informed.

### Overridden guidance

A CDS client may enable the end user to override guidance without providing an explicit reason for doing so. The CDS client can inform the service when a card was dismissed by specifying an outcome of `overridden` without providing an `overrideReason`. This may occur, for example, when the end user viewed the card and dismissed it without providing a reason why.


```json
POST {baseUrl}/cds-services/{serviceId}/feedback

{
   "feedback":[
      {
         "card":"f6b95768-b1c8-40dc-8385-bf3504b82ffb", // uuid from `card.uuid`
         "outcome":"overridden",
         "outcomeTimestamp": "2020-12-11T00:00:00Z"
      }
   ]
}

```

### Explicit reject with override reasons

A CDS client can inform the service when a card was rejected by POSTing an outcome of `overridden` along with an `overrideReason` to the service's feedback endpoint. The CDS Client may enable the clinician to supplement the `overrideReason` with a free text comment, supplied to the CDS Service in `overrideReason.userComment`.

#### OverrideReason

Each **OverrideReason** is described by the following attributes, in the feedback POST to the CDS Service.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`reason` | CONDITIONAL |**Coding** | The Coding object representing the override reason selected by the end user. Required if user selected an override reason from the list of reasons provided in the Card (instead of only leaving a userComment).
`userComment` | OPTIONAL | *string* | The CDS Client may enable the clinician to further explain why the card was rejected with free text. That user comment may be communicated to the CDS Service as a `userComment`.

```json
POST {baseUrl}/cds-services/{serviceId}/feedback

{
   "feedback":[{
         "card":"9368d37b-283f-44a0-93ea-547cebab93ed",
         "outcome":"overridden",
         "overrideReason": {
	 	"reason": {
	 		"code":"d7ecf885",
     			"system":"https://example.com/cds-hooks/override-reason-system"
		},
		"userComment" : "clinician entered comment"
	},
         "outcomeTimestamp": "2020-12-11T00:00:00Z"
      }]
}
```

## Security and Safety

Security and safety risks associated with the CDS Hooks API include:

1.	The risk that confidential information and privileged authorizations transmitted between a CDS Client and a CDS Service could be surreptitiously intercepted by an attacker;
2.	The risk that an attacker masquerading as a legitimate CDS Service could receive confidential information or privileged authorizations from a CDS Client, or could provide to a CDS Client decision support recommendations that could be harmful to a patient;
3.	The risk that an attacker masquerading as a legitimate service-subscribing CDS Client (i.e., man-in-the-middle) could intercept and possibly alter data exchanged between the two parties.
4.	The risk that a CDS Service could embed dangerous suggestions or links to dangerous apps in Cards returned to a CDS Client.
5.	The risk that a CDS Hooks browser-based deployment could be victimized by a Cross-Origin Resource Sharing (CORS) attack.
6.	The risk that a CDS Service could return a decision based on outdated patient data, resulting in a safety risk to the patient.

CDS Hooks defines a security model that addresses these risks by assuring that the identities of both the CDS Service and the CDS Client are authenticated to each other; by protecting confidential information and privileged authorizations shared between a CDS Client and a CDS Service; by recommending means of assuring data freshness; and by incorporating business mechanisms through which trust is established and maintained between a CDS Client and a CDS Service.

### Trusting CDS Services

Prior to enabling CDS Clients to request decision support from any CDS Service, the CDS Client vendor and/or provider organization is expected to perform due diligence on the CDS Service provider.  Each CDS Client vendor/provider is individually responsible for determining the suitability, safety and integrity of the CDS Services it uses, based on the organization's own risk-management strategy.  Each CDS Client vendor/provider SHOULD maintain an "allow list" (and/or "deny list") of the CDS Services it has vetted, and the Card links that have been deemed safe to display from within the CDS Client context. Each provider organization is expected to work with its CDS Client vendor to choose what CDS Services to allow and to negotiate the conditions under which the CDS Services MAY be called.

Once a CDS Service provider is selected, the CDS Client vendor/provider negotiates the terms under which service will be provided.  This negotiation includes agreement on patient data elements that will be prefetched and provided to the CDS Service, data elements that will be made available through an access token passed by the CDS Client, and steps the CDS Service MUST take to protect patient data and access tokens.  The CDS Service can be registered as a client to the CDS Client authorization server, in part to define the FHIR resources that the CDS Service has authorization to access. These business arrangements are documented in the service agreement.

Every interaction between an CDS Client and a CDS Service is initiated by the CDS Client sending a service request to a CDS Service endpoint protected using the [Transport Layer Security protocol](https://tools.ietf.org/html/rfc5246). Through the TLS protocol the identity of the CDS Service is authenticated, and an encrypted transmission channel is established between the CDS Client and the CDS Service. Both the Discovery endpoint and individual CDS Service endpoints are TLS secured.

The authorization server is responsible for enforcing restrictions on the CDS Services that MAY be called and the scope of the FHIR resources that MAY be prefetched or retrieved from the FHIR server.  If a CDS Client is satisfying prefetch requests from a CDS Service or sends a non-null `fhirAuthorization` object to a CDS Service so that it can call the FHIR server, the CDS Service MUST be pre-registered with the authorization server protecting access to the FHIR server.  Pre-registration includes registering a CDS client identifier, and agreeing upon the scope of FHIR access that is minimally necessary to provide the clinical decision support required. This specification does not address how the CDS Client, authorization server, and CDS Service perform this pre-registration.

### Trusting CDS Clients

The service agreement negotiated between the CDS Client vendor/provider and the CDS Service provider will include obligations the CDS Client vendor/provider commits to the CDS Service provider. Some agreements MAY include the use of mutual TLS, in which both ends of the channel are authenticated.

However, mutual TLS is impractical for many organizations. In the absence of mutual TLS, only the CDS Service endpoint will be authenticated because the CDS Client initiates the TLS channel set-up.  To enable the CDS Service to authenticate the identity of the CDS Client, CDS Hooks uses digitally signed [JSON web tokens (JWT)](https://jwt.io/) ([rfc7519](https://tools.ietf.org/html/rfc7519)).


Each time a CDS Client transmits a request to a CDS Service, the request MUST include an `Authorization` header presenting the JWT as a “Bearer” token:
```
Authorization:  Bearer {{JWT}}
```
Note that this is for every single CDS Service call, whether that be a Discovery call, a single CDS Service invocation, or multiple exchanges relating to a single service. Also note that mutual TLS MAY be used alongside JSON web tokens to establish trust of the CDS Client by the CDS Service.

The CDS Client MUST use its private key to digitally sign the JWT, using the [JSON Web Signatures (rfc7515)](https://tools.ietf.org/html/rfc7515) standard.

The JWT header contains the following fields (see [rfc7515 section 4.1](https://tools.ietf.org/html/rfc7515#section-4.1) for further information on these standard headers):

Field | Optionality | Type | Value
----- | ----- | ----- | --------
alg | REQUIRED | *string* | The cryptographic algorithm used to sign this JWT.
kid | REQUIRED | *string* | The identifier of the key-pair used to sign this JWT. This identifier MUST be unique within the CDS Client's JWK Set.
typ | REQUIRED | *string* | Fixed value: `JWT`
jku | OPTIONAL | *url*    | The URL to the JWK Set containing the public key(s).

The JWT payload contains the following fields:

Field | Optionality | Type | Value
----- | ----- | ----- | --------
iss | REQUIRED | *string* | The URI of the issuer of this JWT.  Note that the JWT MAY be self-issued by the CDS Client, or MAY be issued by a third-party identity provider.
aud | REQUIRED | *string* or *array of string* | The CDS Service endpoint that is being called by the CDS Client. (See more details below).
exp | REQUIRED | *number* | Expiration time integer for this authentication JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC).
iat | REQUIRED | *number* | The time at which this JWT was issued, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC).
jti | REQUIRED | *string* | A nonce string value that uniquely identifies this authentication JWT (used to protect against replay attacks).
tenant | OPTIONAL | *string* | An opaque string identifying the healthcare organization that is invoking the CDS Hooks request.

CDS Services SHOULD maintain an allowlist of the `iss` and `jku` fields to only the CDS Clients they trust.

Per [rfc7519](https://tools.ietf.org/html/rfc7519#section-4.1.3), the `aud` value is either a string or an array of strings. For CDS Hooks, this value MUST be the URL of the CDS Service endpoint being invoked. For example, consider a CDS Service available at a base URL of `https://cds.example.org`. When the CDS Client invokes the CDS Service discovery endpoint, the aud value is either `"https://cds.example.org/cds-services"` or `["https://cds.example.org/cds-services"]`. Similarly, when the CDS Client invokes a particular CDS Service (say, `some-service`), the aud value is either `"https://cds.example.org/cds-services/some-service"` or `["https://cds.example.org/cds-services/some-service"]`.

The CDS Client MUST make its public key, expressed as a JSON Web Key (JWK) in a JWK Set, as defined by [rfc7517](https://tools.ietf.org/html/rfc7517). The `kid` value from the JWT header allows a CDS Service to identify the correct JWK in the JWK Set that can be used to verify the signature.

The CDS Client MAY make its JWK Set available via a URL identified by the `jku` header field, as defined by [rfc7515 4.1.2](https://tools.ietf.org/html/rfc7515#section-4.1.2). If the `jku` header field is ommitted, the CDS Client and CDS Service SHALL communicate the JWK Set out-of-band.

#### JWT Signing Algorithm

The cryptographic signing algorithm of JWT is indicated in the `alg` header field. [JSON Web Algorithms (rfc7518)](https://tools.ietf.org/html/rfc7518) defines several cryptographic algorithms for use in signing JWTs and should be referenced by CDS Hooks implementers.

JWTs SHALL NOT be signed used the `none` algorithm, referred to in rfc7518 as unsecured JSON Web Signatures, as the lack of a cryptographic signature does not provide any integrity protection. Such JWTs could not be used by a CDS Service to identity the CDS Client preventing an establishment of trust.

JWTs SHALL NOT be signed using any symmetric algorithm as these algorithms require the CDS Client and CDS Service to share a private key in order to verify the signature. For example, all HMAC based algorithms rely upon a shared private key and thus SHALL NOT be used to sign a JWT.

When choosing an algorithm to sign their JWTs, CDS Clients SHOULD consider not only the algorithms (and key sizes) that are recommended within the security industry, but also how well those algorithms are supported in the various programming languages and libraries that may be used by CDS Services.

At publication time of this specification, both ES384 and RS384 are RECOMMENDED for their regard within the larger security industry, strength, and support across popular programming languages and libraries. However, stronger and better algorithms are continually being introduced due to new threats, weaknesses, and increases in computing power. CDS Clients SHOULD continually re-evaluate their choice of an algorithm based upon these ever changing conditions.

CDS Services SHOULD consider the algorithms they understand and trust based upon their tolerance for risk.

#### Example

An example JSON web token header, payload, and JWK set:

```json
// JSON Web Token Header
{
  "alg": "ES384",
  "typ": "JWT",
  "kid": "example-kid",
  "jku": "https://fhir-ehr.example.com/jwk_uri"
}

// JSON Web Token Payload
{
  "iss": "https://fhir-ehr.example.com/",
  "aud": "https://cds.example.org/cds-services/some-service",
  "exp": 1422568860,
  "iat": 1311280970,
  "jti": "ee22b021-e1b7-4611-ba5b-8eec6a33ac1e",
  "tenant": "2ddd6c3a-8e9a-44c6-a305-52111ad302a2"
}

// JSON Web Key Set (public key)
// This public key is used by the CDS Service to verify the signature of the JWT
{  
  "keys":[  
    {  
      "kty": "EC",
      "use": "sig",
      "crv": "P-384",
      "kid": "example-kid",
      "x": "46SDH7Znh821wblCBglA61sNE9ZrHYKKt3qRtRTmSXyOI_FIGBLWrWa0GPUkDCEk",
      "y": "XMcRuuoGW7CXjQdy-F5i3FeBE0x9hPLdeFdSoDd3ELmx404tLX0VRRcqzAsPhXcI",
      "alg": "ES384"
    }
  ]
}

// JSON Web Key (private key)
// This private key is used by the CDS Client to sign the JWT
{  
  "kty": "EC",
  "d": "SeFXUXda8UomZ8GFUl7HH_Oi15rIbfMcsWj9ecIsDR8kLbqsEz2CGNgwy_IcILxy",
  "use": "sig",
  "crv": "P-384",
  "kid": "example-kid",
  "x": "46SDH7Znh821wblCBglA61sNE9ZrHYKKt3qRtRTmSXyOI_FIGBLWrWa0GPUkDCEk",
  "y": "XMcRuuoGW7CXjQdy-F5i3FeBE0x9hPLdeFdSoDd3ELmx404tLX0VRRcqzAsPhXcI",
  "alg": "ES384"
}
```

Using the above JWT values and JWKs, the complete JWT as passed in the Authorization HTTP header would be:

```
Authorization: Bearer eyJhbGciOiJFUzM4NCIsInR5cCI6IkpXVCIsImtpZCI6ImV4YW1wbGUta2lkIiwiamt1IjoiaHR0cHM6Ly9maGlyLWVoci5leGFtcGxlLmNvbS9qd2tfdXJpIn0.eyJpc3MiOiJodHRwczovL2ZoaXItZWhyLmV4YW1wbGUuY29tLyIsInN1YiI6ImNsaWVudF9pZCIsImF1ZCI6Imh0dHBzOi8vY2RzLmV4YW1wbGUub3JnL2Nkcy1zZXJ2aWNlcy9zb21lLXNlcnZpY2UiLCJleHAiOjE0MjI1Njg4NjAsImlhdCI6MTMxMTI4MDk3MCwianRpIjoiZWUyMmIwMjEtZTFiNy00NjExLWJhNWItOGVlYzZhMzNhYzFlIiwidGVuYW50IjoiMmRkZDZjM2EtOGU5YS00NGM2LWEzMDUtNTIxMTFhZDMwMmEyIn0.CUFPkplnWd6YGIvzoHolWCQBDsCL8QtTWKGg_QFpS169WrqDGzktRi-_we6-6rVzbjerU27ZKww_SW0-b9RTz-dPJNcqsueMio8r6EqXUXhbLm_ch3XFSbDlGHDl_tqo
```

### Cross-Origin Resource Sharing

[Cross-origin resource sharing (CORS)](https://www.w3.org/TR/cors/) is a W3C standard mechanism that uses additional HTTP headers to enable a web browser to gain permission to access resources from an Internet domain different from that from which the browser is currently accessing.  CORS is a client-side security mechanism with well-documented security risks.

CDS Services and browser-based CDS Clients will require CORS support. A secure implementation guide for CORS is outside of the scope of this CDS Hooks specification. Organizations planning to implement CDS Hooks with CORS support are referred to the Cross-Origin Resource Sharing section of the [OWASP HTML5 Security Cheat Sheet]( https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html#cross-origin-resource-sharing).

## Extensions

The specification is not prescriptive about support for extensions. However, to support extensions, the specification reserves the name `extension` and will never define an element with that name, allowing implementations to use it to provide custom behavior and information. The value of an extension element MUST be a pre-coordinated JSON object. The intention here is that anything that has broad ranging value across the community enough to be a standardized extension has broad ranging value enough to be a first class citizen rather than an extension in CDS Hooks.

For example, an extension on a request could look like this:

```json
{
   "hookInstance" : "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
   "fhirServer" : "http://fhir.example.org:9080",
   "hook" : "patient-view",
   "context" : {
       "userId" : "Practitioner/example"
   },
   "extension" : {
      "com.example.timestamp": "2017-11-27T22:13:25Z",
      "com.cds-hooks.sandbox.myextension-practitionerspecialty" : "gastroenterology"
   }
}
```

As another example, an extension defined on the discovery response could look like this:

```json
{
  "services": [
    {
      "title": "Example CDS Service Discovery",
      "hook": "patient-view",
      "id": "patientview",
      "prefetch": {
        "patient": "Patient/{{context.patientId}}"
      },
      "description": "clinical decision support for patient view",
      "extension": {
          "example-client-conformance": "http://hooks.example.org/fhir/102/Conformance/patientview"
      }
    }
  ]
}
```
[OAuth 2.0]: https://oauth.net/2/

## Data Types

CDS Hooks leverages json data types throughout.  This section defines data structures re-used across the specification.

### Coding

The **Coding** data type captures the concept of a code. A code is understood only when the given code, code-system, and a optionally a human readable display are available. This coding type is a standalone data type in CDS Hooks modeled after a trimmed down version of the [FHIR Coding data type](http://hl7.org/fhir/datatypes.html#Coding).

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`code` | REQUIRED | *string* | The code for what is being represented
`system` | OPTIONAL | *string* | A codesystem for this `code`.
`display` | OPTIONAL | *string* | A short, human-readable label to display.

## Hooks

### Overview

As a specification, CDS Hooks does not prescribe a default or required set of hooks for implementers. Rather, the set of hooks defined here are merely a set of common use cases that were used to aid in the creation of CDS Hooks. The set of hooks defined here are not a closed set; anyone is able to define new hooks to fit their use cases and propose those hooks to the community. New hooks are proposed in a prescribed [format](#hook-definition-format) using the [documentation template](../../hooks/template) by submitting a [pull request](https://github.com/cds-hooks/docs/tree/master/docs/hooks). Hooks are [versioned](#hook-version), and mature according to the [Hook Maturity Model](#hook-maturity-model).

Note that each hook (e.g. `order-select`) represents something the user is doing in the CDS Client and multiple CDS Services might respond to the same hook (e.g. a "price check" service and a "prior authorization" service might both respond to `order-select`).

### Hook context and prefetch

#### What's the difference?

Any user workflow or action within a CDS Client will naturally include contextual information such as the current user and patient. CDS Hooks refers to this information as _context_ and allows each hook to define the information that is available in the context. Because CDS Hooks is intended to support usage within any CDS Client, this context can contain both required and optional data, depending on the capabilities of individual CDS Clients. However, the context information is intended to be relevant to most CDS Services subscribing to the hook.

For example, consider a simple `patient-view` hook that is invoked whenever the user views a patient's information within the CDS Client. At this point in the workflow, the contextual information would include at least the current user and the patient that is being viewed. The hook declares this as `context`, and passes it to the CDS Service as part of the request in the `context` field:

```json
"context":{
  "userId" : "PractitionerRole/123",
  "patientId" : "1288992"
}
```

Prefetch data, on the other hand, is defined by CDS Services as a way to allow the CDS Client to provide the data that a CDS Service needs as part of the initial request to the service. When the context data relates to a FHIR resource, it is important not to conflate context and prefetch. For instance, in the hook described above for opening a patient's chart, the hook includes the id of the patient whose chart is being opened, not the full patient FHIR resource. In this case, the FHIR identifier of the patient is appropriate as CDS Services may not be interested in details about the patient resource but instead other data related to this patient. Or, a CDS Service may only need the full patient resource in certain scenarios. Therefore, including the full patient resource in context would be unnecessary. For CDS Services that want the full patient resource, they can request it to be prefetched or fetch it as needed from the FHIR server using a prefetch template in their discovery response, such as:

```json
"prefetch": {
  "patientToGreet": "Patient/{{context.patientId}}"
}
```

See the section on [prefetch tokens](#prefetch-tokens) for more information on how contextual information can be used to parameterize prefetch templates.

Consider another hook for when a new patient is being registered. In this case, it would likely be appropriate for the context to contain the full FHIR resource for the patient being registered as the patient may not be yet recorded in the CDS Client (and thus not available from the FHIR server) and CDS Services using this hook would predominantly be interested in the details of the patient being registered.

Additionally, consider a PGX CDS Service and a Zika screening CDS Service, each of which is subscribed to the same hook. The context data specified by their shared hook should contain data relevant to both CDS Services; however, each service will have other specific data needs that will necessitate disparate prefetch requests. For instance, the PGX CDS Service likely is interested in genomics data whereas the Zika screening CDS Service will want Observations.

In summary, context is specified in the hook definition to guide developers on the information available at the point in the workflow when the hook is triggered. Prefetch data is defined by each CDS Service because it is specific to the information that service needs in order to process.

### Hook Definition Format

Hooks are defined in the following format.

#### `hook-name-expressed-as-noun-verb`

The name of the hook SHOULD succinctly and clearly describe the activity or event. Hook names are unique so hook creators SHOULD take care to ensure newly proposed hooks do not conflict with an existing hook name. Hook creators SHALL name their hook with reverse domain notation (e.g. `org.example.patient-transmogrify`) if the hook is specific to an organization. Reverse domain notation SHALL not be used by a standard hooks catalog.

When naming hooks, the name should start with the subject (noun) of the hook and be followed by the activity (verb). For example, `patient-view` (not `view-patient`) or `order-sign` (not `sign-order`).

#### Workflow

Describe when this hook occurs in a workflow. Hook creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementors.

### Context

Describe the set of contextual data used by this hook. Only data logically and necessarily associated with the purpose of this hook should be represented in context.

All fields defined by the hook's context MUST be defined in a table where each field is described by the following attributes:

- Field: The name of the field in the context JSON object. Hook authors SHOULD name their context fields to be consistent with other existing hooks when referring to the same context field.
- Optionality: A string value of either `REQUIRED` or `OPTIONAL`
- Prefetch Token: A string value of either `Yes` or `No`, indicating whether this field can be tokenized in a prefetch template.
- Type: The type of the field in the context JSON object, expressed as the JSON type, or the name of a FHIR Resource type. Valid types are *boolean*, *string*, *number*, *object*, *array*, or the name of a FHIR resource type. When a field can be of multiple types, type names MUST be separated by a *pipe* (`|`)
- Description: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

The table below illustrates a sample hook context table:

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`someField` | REQUIRED | Yes | *string* | A clear description of the value of this field.
`anotherField` | OPTIONAL | No | *number* | A clear description of the value of this field.
`someObject` | REQUIRED | No | *object* | A clear description of the value of this field.
`moreObjects` | OPTIONAL | No | *array* | A clear description of the items in this array.
`allFHIR` | OPTIONAL | No | *object* | A FHIR Bundle of the following FHIR resources using a specific version of FHIR.

#### FHIR resources in context

For context fields that may contain multiple FHIR resources, the field SHOULD be defined as a FHIR Bundle, rather than as an array of FHIR resources. For example, multiple FHIR resources are necessary to describe all of the orders under review in the `order-sign` hook's `draftOrders` field. Hook definitions SHOULD prefer the use of FHIR Bundles over other bespoke data structures.

Often, context is populated with in-progress or in-memory data that may not yet be available from the FHIR server. For example, imagine a hook, `order-select` that is invoked when a user selects a medication durating an order workflow. The context data for this hook would contain draft FHIR resources representing the medications that have been selected for ordering. In this case, the CDS Client should only provide these draft resources and not the full set of orders available from its FHIR server. The CDS service MAY pre-fetch or query for FHIR resources with other statuses.

All FHIR resources in context MUST be based on the same FHIR version.

#### Examples

Hook creators SHOULD include examples of the context.

```json
"context":{
  "someField":"foo",
  "anotherField":123,
  "someObject": {
    "color": "red",
    "version": 1
  },
  "moreObjects":[]
}
```

If the context contains FHIR data, hook creators SHOULD include examples across multiple versions of FHIR if differences across FHIR versions are possible.

### Hook Maturity Model
The intent of the CDS Hooks Maturity Model is to attain broad community engagement and consensus, before a hook is labeled as mature, that the hook is necessary, implementable, and worthwhile to the CDS services and CDS clients that would reasonably be expected to use it. Implementer feedback should drive the maturity of new hooks. Diverse participation in open developer forums and events, such as HL7 FHIR Connectathons, is necessary to achieve significant implementer feedback. The below criteria will be evaluated with these goals in mind.

    Hook maturity | 3 - Considered

The Hook maturity levels use the term CDS client to generically refer to the clinical workflow system in which a CDS services returned cards are displayed.

Maturity Level | Maturity title | Requirements
--- | --- | ---
0 | Draft | Hook is defined according to the [hook definition format](#hook-definition-format).
1 | Submitted  | _The above, and …_ Hook definition is written up as a [github pull request](https://github.com/cds-hooks/docs/tree/master/docs/hooks) using the [Hook template](../../hooks/template/) and community feedback is solicited on the [zulip CDS Hooks stream](https://chat.fhir.org/#narrow/stream/179159-cds-hooks).
2 | Tested | _The above, and …_ The hook has been tested and successfully supports interoperability among at least one CDS client and two independent CDS services using semi-realistic data and scenarios (e.g. at a FHIR Connectathon). The github pull request defining the hook is approved and published by the CDS Hooks Project Management Committee.
3 | Considered |  _The above, and …_ At least 3 distinct organizations recorded ten distinct implementer comments (including a github issue, tracker item, or comment on the hook definition page), including at least two CDS clients and three independent CDS services. The hook has been tested at two connectathons.
4 | Documented | _The above, and …_ The author agrees that the artifact is sufficiently stable to require implementer consultation for subsequent non-backward compatible changes.  The hook is implemented in the standard CDS Hooks sandbox and multiple prototype projects. The Hook specification SHALL: <ul><ol>Identify a broad set of example contexts in which the hook may be used with a minimum of three, but as many as 8-10.</ol><ol>Clearly differentiate the hook from similar hooks or other standards to help an implementer determine if the hook is correct for their scenario.</ol><ol>Explicitly document example scenarios when the hook should not be used.</ol></ul>
5 | Mature | _The above, and ..._ The hook has been implemented in production in at least two CDS clients and three independent CDS services. An HL7 working group ballots the hook and the hook has passed HL7 STU ballot.
6 | Normative | _The above, and ..._ the responsible HL7 working group and the CDS working group agree the material is ready to lock down and the hook has passed HL7 normative ballot


### Changes to a Hook

Each hook MUST include a Metadata table at the beginning of the hook with the specification version and hook version as described in the following sections.

#### Specification Version

Because hooks are such an integral part of the CDS Hooks specification, hook definitions are associated with specific versions of the specification. The hook definition MUST include the version (or versions) of the CDS Hooks specification that it is defined to work with.

    specificationVersion | 1.0

Because the specification itself follows semantic versioning, the version specified here is a minimum specification version. In other words, a hook defined to work against 1.0 should continue to work against the 1.1 version of CDS Hooks. However, a hook that specifies 1.1 would not be expected to work in a CDS Hooks 1.0 environment.

#### Hook Version

To enable tracking of changes to hook definitions, each hook MUST include a version indicator, expressed as a string.

    hookVersion | 1.0

To help ensure the stability of CDS Hooks implementations, once a hook has been defined (i.e. published with a particular name so that it is available for implementation), breaking changes MUST NOT be made. This means that fields can be added and restrictions relaxed, but fields cannot be changed, and restrictions cannot be tightened.

In particular, the semantics of a hook (i.e. the meaning of the hook from the perspective of the CDS Client) cannot be changed. CDS Clients that implement specific hooks are responsible for ensuring the hook is called from the appropriate point in the workflow.

Note that this means that the name of the hook carries major version semantics. That is not to say that the name must include the major version, that is left as a choice to authors of the specification. For example, following version 1.x, the major version MAY be included in the name as "-2", "-3", etc. Eg: patient-view-2, patient-view-3, etc. Clean hook names increase usability. Ideally, an active hook name accurately defines the meaning and workflow of the hook in actual words.

The following types of changes are possible for a hook definition:

Change | Version Impact
------ | ----
Clarifications and corrections to documentation that do not impact functionality | Patch
Change of prefetch token status of an existing context field | Major
Addition of a new, REQUIRED field to the context | Major
Addition of a new, OPTIONAL field to the context | Minor
Change of optionality of an existing context field | Major
Change of type or cardinality of an existing context field | Major
Removal of an existing context field | Major
Change of semantics of an existing context field | Major
Change of semantics of the hook | Major

When a major change is made, the hook definition MUST be published under a new name. When a minor or patch change is made, the hook version MUST be updated. Hook definers MUST use [semantic versioning](https://semver.org/) to communicate the impact of changes in an industry standard way.

> Note that the intent of this table is to outline possible breaking changes. The authors have attempted to enumerate these types of changes exhaustively, but as new types of breaking changes are identified, this list will be updated.

#### Hook Maturity
As each hook progresses through a process of being defined, tested, implemented, used in production environments, and balloted, the hook's formal maturity level increases. Each hook has its own maturity level, which MUST be defined in the hook's definition and correspond to the [Hook Maturity Model](#hook-maturity-model).

    hookMaturity | 0 - Draft

#### Change Log

Changes made to a hook's definition MUST be documented in a change log to ensure hook consumers can track what has been changed over the life of a hook. The change log MUST contain the following elements:

- Version: The version of the change
- Description: A description of the change and its impact

For example:

Version | Description
---- | ----
1.1 | Added new context variable
1.0.1 | Clarified context variable usage
1.0 | Initial Release
