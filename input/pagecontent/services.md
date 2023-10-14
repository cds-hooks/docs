### Conformance Language
The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this specification are to be interpreted as described in [RFC2119](https://tools.ietf.org/html/rfc2119). Further, the key word "CONDITIONAL" indicates that a particular item is either REQUIRED or OPTIONAL, based upon another item.

### Use of JSON

All data exchanged through production RESTful APIs MUST be sent and received as [JSON](https://tools.ietf.org/html/rfc8259) (JavaScript Object Notation) structures and are transmitted over HTTPS. See [Security and Safety](security.html#security-and-safety) section.

**Null and empty JSON elements**

* JSON elements SHALL NOT be null, unless otherwise specified.
* JSON elements SHALL NOT be empty, unless otherwise specified (e.g. to indicate [no guidance with an empty array of cards](#http-response) in the CDS Hooks response).

If a JSON attribute is defined as OPTIONAL, and does not have a value, implementers MUST omit it. For instance, OPTIONAL JSON string and array attributes are omitted rather than having a null or empty value.

Unless otherwise specified, JSON attribute values SHALL NOT be null or empty, so `null`, `""`, `[]`, or `{}` are prohibited. If a JSON attribute is defined with as OPTIONAL, and does not have a value, implementers SHALL omit it.

## Discovery
A CDS Service is discoverable via a stable endpoint by CDS Clients. The Discovery endpoint includes information such as a description of the CDS Service, when it should be invoked, and any data that is requested to be prefetched.

A CDS Service provider exposes its discovery endpoint at:

```shell
{baseURL}/cds-services
```
### HTTP Request

The Discovery endpoint SHALL always be available at `{baseUrl}/cds-services`. For example, if the `baseUrl` is https://example.com, the CDS Client can retrieve the list of CDS Services by invoking:

`GET https://example.com/cds-services`

### Response

The response to the discovery endpoint SHALL be an object containing a list of CDS Services.

Field | Description
----- | ---------
`services` | *array*. An array of **CDS Services**.
{:.grid}

If your CDS server hosts no CDS Services, the discovery endpoint should return a 200 HTTP response with an empty array of services.

Each CDS Service SHALL be described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | ---------
`hook`| REQUIRED | *string* | The hook this service should be invoked on. See [Hooks](hooks.html).
`title`| RECOMMENDED | *string* | The human-friendly name of this service.
`description`| REQUIRED | *string* | The description of this service.
`id` | REQUIRED | *string* | The {id} portion of the URL to this service which is available at<br />`{baseUrl}/cds-services/{id}`
`prefetch` | OPTIONAL | *object* | An object containing key/value pairs of FHIR queries that this service is requesting the CDS Client to perform and provide on each service call. The key is a *string* that describes the type of data being requested and the value is a *string* representing the FHIR query.<br />See [Prefetch Template](#prefetch-template).
`usageRequirements`| OPTIONAL | *string* | Human-friendly description of any preconditions for the use of this CDS Service.
{:.grid}

Note that a CDS server can host multiple entries of CDS service with the same `id` for different `hook`s. This allows a service to update its advice based on changes in workflow as discussed in [*update stale guidance*](security.html#update-stale-guidance).

### HTTP Status Codes

Code | Description
---- | -----------
`200 OK` | A successful response.
{:.grid}

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
        "patientToGreet": "Patient/{% raw  %}{{{% endraw  %}context.patientId}}"
      }
    },
    {
      "hook": "order-select",
      "title": "Order Echo CDS Service",
      "description": "An example of a CDS Service that simply echoes the order(s) being placed",
      "id": "order-echo",
      "prefetch": {
        "patient": "Patient/{% raw  %}{{{% endraw  %}context.patientId}}",
        "medications": "MedicationRequest?patient={% raw  %}{{{% endraw  %}context.patientId}}"
      }
    },
    {
      "hook": "order-sign",
      "title": "Pharmacogenomics CDS Service",
      "description": "An example of a more advanced, precision medicine CDS Service",
      "id": "pgx-on-order-sign",
      "usageRequirements": "Note: functionality of this CDS Service is degraded without access to a FHIR Restful API as part of CDS recommendation generation."
    }
  ]
}
```


## Calling a CDS Service

### HTTP Request

A CDS Client SHALL call a CDS Service by `POST`ing a JSON document to the service as described in this section. The CDS Service endpoint can be constructed from the CDS Service base URL and an individual service id as `{baseUrl}/cds-services/{service.id}`. CDS Clients may add additional requirements for the triggering of a hook, based upon the user, workflow, CDS Service or other reasons (e.g. if the service is provided by a payer, the patient has active coverage with that payer). See [Trusting CDS Services](security.html#trusting-cds-services) for additional considerations.

The request SHALL include a JSON `POST` body with the following input fields:

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`hook` | REQUIRED | *string* | The hook that triggered this CDS Service call. See [Hooks](hooks.html).
`hookInstance` | REQUIRED | *string* | A universally unique identifier (UUID) for this particular hook call (see more information below).
`fhirServer` | CONDITIONAL | *URL* | The base URL of the CDS Client's [FHIR](https://www.hl7.org/fhir/) server. If fhirAuthorization is provided, this field is REQUIRED.  The scheme MUST be `https` when production data is exchanged.
`fhirAuthorization` | OPTIONAL | *object* | A structure holding an [OAuth 2.0](https://oauth.net/2/) bearer access token granting the CDS Service access to FHIR resources, along with supplemental information relating to the token. See the [FHIR Resource Access](#fhir-resource-access) section for more information.
`context` | REQUIRED | *object* | Hook-specific contextual data that the CDS service will need.<br />For example, with the `patient-view` hook this will include the FHIR id of the [Patient](https://www.hl7.org/fhir/patient.html) being viewed.  For details, see the Hooks specific specification page (example: [patient-view](hooks/patient-view)).
`prefetch` | OPTIONAL | *object* | The FHIR data that was prefetched by the CDS Client (see more information below).
{:.grid}

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
  "hookInstance": "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
  "fhirServer": "http://hooks.smarthealthit.org:9080",
  "hook": "patient-view",
  "fhirAuthorization": {
    "access_token": "some-opaque-fhir-access-token",
    "token_type": "Bearer",
    "expires_in": 300,
    "scope": "user/Patient.read user/Observation.read",
    "subject": "cds-service4"
  },
  "context": {
    "userId": "Practitioner/example",
    "patientId": "1288992",
    "encounterId": "89284"
  },
  "prefetch": {
    "patientToGreet": {
      "resourceType": "Patient",
      "gender": "male",
      "birthDate": "1925-12-23",
      "id": "1288992",
      "active": true
    }
  }
}
```


## Providing FHIR Resources to a CDS Service

CDS Services require specific FHIR resources in order to compute the recommendations the CDS Client requests. If real-world performance were no issue, a CDS Client could launch a CDS Service passing only context data (such as the current user and patient ids), and the CDS Service could obtain authorization to access the CDS Client's FHIR API, retrieving any resources required via FHIR read or search interactions. Given that CDS Services SHOULD respond quickly (on the order of 500 ms.), this specification defines  mechanisms that allow a CDS Service to request and obtain FHIR resources more efficiently.

Two optional methods are provided.  In the first method, FHIR resources MAY be obtained by passing "prefetched" data from the CDS Client to the CDS Service in the service call. If data is to be prefetched, the CDS Service registers a set of "prefetch templates" with the CDS Client, as described in the [Prefetch Template](#prefetch-template) section below. These "prefetch templates" are defined in the [CDS Service discovery response](#response). The FHIR resources are passed as key-value pairs, with each key matching a key described in the discovery response, and each value being a FHIR resource. Note that in the case of searches, this resource may be a [`searchset`](http://hl7.org/fhir/bundle.html#searchset) Bundle.

The second method enables the CDS Service to retrieve FHIR resources for itself, without the need to request and obtain its own authorization.  If the CDS Client decides to have the CDS Service fetch its own FHIR resources, the CDS Client obtains and passes directly to the CDS Service a bearer token issued for the CDS Service's use in executing FHIR API calls against the CDS Client's FHIR server to obtain the required resources.  Some CDS Clients MAY pass prefetched data, along with a bearer token for the CDS Service to use if additional resources are required.

Each CDS Client SHOULD decide which approach, or combination, is preferred, based on performance considerations and assessment of attendant security and safety risks. CDS Services should be capable of accessing FHIR resources via either prefetch or from the CDS Client's FHIR server.  For more detail, see the [FHIR Resource Access](#fhir-resource-access) section below.

Similarly, each CDS Client will decide what FHIR resources to authorize and to prefetch, based on the CDS Service discovery response's "prefetch" request and on the provider's assessment of the "minimum necessary."  The CDS Client provider and the CDS Service provider will negotiate the set of FHIR resources to be provided, and how these data will be provided, as part of their service agreement.

### Prefetch Template

A _prefetch template_ is a FHIR [`read`](http://hl7.org/fhir/http.html#read) or [`search`](http://hl7.org/fhir/http.html#search) request that describes relevant data needed by the CDS Service. For example, the following is a prefetch template for hemoglobin A1c observations:

```
Observation?patient={% raw  %}{{{% endraw  %}context.patientId}}&code=4548-4&_count=1&sort:desc=date
```

To allow for prefetch templates that are dependent on the workflow context, prefetch templates may include references to context using [_prefetch tokens_](#prefetch-tokens). In the above example, `{% raw  %}{{{% endraw  %}context.patientId}}` is a prefetch token.

The `prefetch` field of a CDS Service discovery response defines the set of prefetch templates for that service, providing a _prefetch key_ for each one that is used to identify the prefetch data in the CDS request. For example:

```json
{
  "prefetch": {
    "hemoglobin-a1c": "Observation?patient={% raw  %}{{{% endraw  %}context.patientId}}&code=4548-4&_count=1&sort:desc=date"
  }
}
```

In this `prefetch`, `hemoglobin-a1c` is the prefetch key for this prefetch template. For a complete worked example, see [below](#example-prefetch-templates).

A CDS Client MAY choose to honor zero, some, or all of the desired prefetch templates, and is free to choose the most appropriate source for these data. For example:

- The CDS Client MAY have some of the desired prefetched data already in memory, thereby removing the need for any network call
- The CDS Client MAY compute an efficient set of prefetch templates from multiple CDS Services, thereby reducing the number of calls to a minimum
- The CDS Client MAY satisfy some of the desired prefetched templates via some internal service or even its own FHIR server.

The CDS Client SHALL only provide access to resources that are within the user's authorized scope.

As part of preparing the request, a CDS Client processes each prefetch template it intends to satisfy by replacing the prefetch tokens in the prefetch template to construct a relative FHIR request URL. This specification is not prescriptive about how this request is actually processed. The relative URL may be appended to the base URL for the CDS Client's FHIR server and directly invoked, or the CDS Client may use internal infrastructure to satisfy the request in the same way that invoking against the FHIR server would.

Regardless of how the CDS Client satisfies the prefetch templates (if at all), the prefetched data given to the CDS Service MUST be equivalent to the data the CDS Service would receive if it were making its own call to the CDS Client's FHIR server using the parameterized prefetch template.

> Note that this means that CDS services will receive only the information they have requested and are authorized to receive. Prefetch data for other services registered to the same hook MUST NOT be provided. In other words, services SHALL only receive the data they requested in their prefetch.

The resulting response is passed along to the CDS Service using the `prefetch` parameter (see [below](#example-prefetch-templates). 

> Note that a CDS Client MAY paginate prefetch results. The intent of allowing pagination is to ensure that prefetch queries that may be too large for a single payload can still be retrieved by the service. The decision to paginate and the size of pages is entirely at the CDS Client's discretion. CDS Clients are encouraged to only use pagination when absolutely necessary, keeping performance and user experience in mind.

The CDS Client MUST NOT send any prefetch template key that it chooses not to satisfy. If the CDS Client encounters errors prefetching the requested data, OperationOutcome(s) SHOULD be used to communicate those errors to prevent the CDS Service from incurring an unneeded follow-up query. CDS Clients MUST omit the prefetch key if relevant details cannot be provided (e.g. intermittent connectivity issues). CDS Services SHOULD check any prefetched data for the existence of OperationOutcomes. If the CDS Client has no data to populate a template prefetch key, the prefetch template key MUST have a value of __null__. Note that the __null__ result is used rather than a bundle with zero entries to account for the possibility that the prefetch url is a single-resource request.

It is the CDS Service's responsibility to check prefetched data against its template to determine what requests were satisfied (if any) and to programmatically retrieve any additional necessary data. If the CDS Service is unable to obtain required data because it cannot access the FHIR server and the request did not contain the necessary prefetch keys, the service SHALL respond with an HTTP 412 Precondition Failed status code.

#### Prefetch tokens

A prefetch token is a placeholder in a prefetch template that is _replaced by information from the hook's context_ to construct the FHIR URL used to request the prefetch data.

Prefetch tokens MUST be delimited by `{% raw  %}{{{% endraw  %}` and `}}`, and MUST contain only the qualified path to a hook context field _or one of the following user identifiers: `userPractitionerId`, `userPractitionerRoleId`, `userPatientId`, or `userRelatedPersonId`_.

Individual hooks specify which of their `context` fields can be used as prefetch tokens. Only root-level fields with a primitive value within the `context` object are eligible to be used as prefetch tokens. For example, `{% raw  %}{{{% endraw  %}context.medication.id}}` is not a valid prefetch token because it attempts to access the `id` field of the `medication` field.

##### Prefetch tokens identifying the user
A prefetch template enables a CDS Service to learn more about the current user through a FHIR read, like so:
```
{
  "prefetch": {
    "user": "{% raw  %}{{{% endraw  %}context.userId}}"
  }
}
```
or though a FHIR search:
```
{
  "prefetch": {
    "user": "PractitionerRole?_id={% raw  %}{{{% endraw  %}userPractitionerRoleId}}&_include=PractitionerRole:practitioner"
  }
}
```

A prefetch template may include any of the following prefetch tokens:


Token | Description
---|---
`{% raw  %}{{{% endraw  %}userPractitionerId}}` | FHIR id of the Practitioner resource corresponding to the current user.
`{% raw  %}{{{% endraw  %}userPractitionerRoleId}}`|FHIR id of the PractitionerRole resource corresponding to the current user.
`{% raw  %}{{{% endraw  %}userPatientId}}`|FHIR id of the Patient resource corresponding to the current user.
`{% raw  %}{{{% endraw  %}userRelatedPersonId}}`|FHIR id of the RelatedPerson resource corresponding to the current user.


No single FHIR resource represents a user, rather Practitioner and PractitionerRole may be jointly used to represent a provider, and Patient or RelatedPerson are used to represent a patient or their proxy. Hook definitions typically define a `context.userId` field and corresponding prefetch token.


#### Prefetch query restrictions

To reduce the implementation burden on CDS Clients that support CDS Services, this specification RECOMMENDS that prefetch queries only use a subset of the full functionality available in the FHIR specification. When using this subset, valid prefetch templates MUST only make use of:

* _instance_ level [read](https://www.hl7.org/fhir/http.html#read) interactions (for resources with known ids such as `Patient`, `Practitioner`, or `Encounter`)
* _type_ level [search](https://www.hl7.org/fhir/http.html#search) interactions; e.g. `patient={% raw  %}{{{% endraw  %}context.patientId}}`
* Resource references (e.g. `patient={% raw  %}{{{% endraw  %}context.patientId}}`)
* _token_ search parameters using equality (e.g. `code=4548-4`) and optionally the `:in` modifier (no other modifiers for token parameters)
* _date_ search parameters on `date`, `dateTime`, `instant`, or `Period` types only, and using only the prefixes `eq`, `lt`, `gt`, `ge`, `le`
* the `_count` parameter to limit the number of results returned
* the `_sort` parameter to allow for _most recent_ and _first_ queries

#### Example prefetch token

Often a prefetch template builds on the contextual data associated with the hook. For example, a particular CDS Service might recommend guidance based on a patient's conditions when the chart is opened. The FHIR query to retrieve these conditions might be `Condition?patient=123`. In order to express this as a prefetch template, the CDS Service must express the FHIR id of the patient as a token so that the CDS Client can replace the token with the appropriate value. When context fields are used as tokens, their token name MUST be `context.name-of-the-field`. For example, given a context like:

```json
{
  "context": {
    "patientId": "123"
  }
}
```

The token name would be `{% raw  %}{{{% endraw  %}context.patientId}}`. Again using our above conditions example, the complete prefetch template would be `Condition?patient={% raw  %}{{{% endraw  %}context.patientId}}`.

Only the first level fields in context may be considered for tokens.

For example, given the following context that contains amongst other things, a MedicationRequest FHIR resource:

```json
{
  "context": {
    "encounterId": "456",
    "draftOrders": {
      "resourceType": "Bundle",
      "entry": [ {
          "resource": {
            "resourceType": "MedicationRequest",
            "id": "123",
            "status": "draft",
            "intent": "order",
            "medicationCodeableConcept": {
              "coding": [   {
                  "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
                  "code": "617993",
                  "display": "Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
                }]},
            "subject": {
              "reference": "Patient/1288992"
            }
          }
        }
      ]
    }
  }
}
```

Only the `encounterId` field in this example is eligible to be a prefetch token as it is a first level field and the datatype (string) can be placed into the FHIR query. The MedicationRequest.id value in the context is not eligible to be a prefetch token because it is not a first level field. If the hook creator intends for the MedicationRequest.id value to be available as a prefetch token, it must be made available as a first level field. Using the aforementioned example, we simply add a new `medicationRequestId` field:

```json
{
  "context": {
    "medicationRequestId": "123",
    "encounterId": "456",
    "draftOrders": {
      "resourceType": "Bundle",
      "entry": [ {
          "resource": {
            "resourceType": "MedicationRequest",
            "id": "123",
            "status": "draft",
            "intent": "order",
            "medicationCodeableConcept": {
              "coding": [   {
                  "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
                  "code": "617993",
                  "display": "Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
                }]},
            "subject": {
              "reference": "Patient/1288992"
            }
          }
        }
      ]
    }
  }
}
```

#### Example prefetch templates

```json
{
  "prefetch": {
    "patient": "Patient/{% raw  %}{{{% endraw  %}context.patientId}}",
    "hemoglobin-a1c": "Observation?patient={% raw  %}{{{% endraw  %}context.patientId}}&code=4548-4&_count=1&sort:desc=date",
    "diabetes-type2": "Condition?patient={% raw  %}{{{% endraw  %}context.patientId}}&code=44054006&category=problem-list-item&status=active",
    "user": "PractitionerRole?_id={% raw  %}{{{% endraw  %}userPractitionerRoleId}}"
  }
}
```

Here is an example prefetch field from a CDS Service discovery endpoint. The
goal is to know, at call time:

| Key | Description |
| --- | ----------- |
| `patient` | Patient demographics. |
| `hemoglobin-a1c` | Most recent Hemoglobin A1c reading for this patient. |
| `diabetes-type2` | If the patient has an active condition of diabetes mellitus on their problem list. |
| `user` | Information on the current user.
{:.grid}

#### Example prefetch data

```json
{
  "prefetch": {
    "patient": {
      "resourceType": "Patient",
      "gender": "male",
      "birthDate": "1974-12-25",
      "...": "<snipped for brevity>"
    },
    "hemoglobin-a1c": {
      "resourceType": "Bundle",
      "type": "searchset",
      "entry": [
        {
          "resource": {
            "resourceType": "Observation",
            "code": {
              "coding": [
                {
                  "system": "http://loinc.org",
                  "code": "4548-4",
                  "display": "Hemoglobin A1c"
                }
              ]
            },
            "...": "<snipped for brevity>"
          }
        }
      ]
    },
    "user": "123"
  }
}
```

The CDS Hooks request is augmented to include two prefetch values, where the dictionary
keys match the request keys (`patient` and `hemoglobin-a1c` in this case).

Note that the missing `diabetes-type2` key indicates that either the CDS Client has decided not to satisfy this particular prefetch template or it was not able to retrieve this prefetched data. The CDS Service is responsible for retrieving the FHIR resource representing the user from the FHIR server (if required).

### FHIR Resource Access

If the CDS Client provides both `fhirServer` and `fhirAuthorization` request parameters, the CDS Service MAY use the FHIR server to obtain any FHIR resources for which it's authorized, beyond those provided by the CDS Client as prefetched data. This is similar to the approach used by SMART on FHIR wherein the SMART app requests and ultimately obtains an access token from the CDS Client's Authorization server using the SMART launch workflow, as described in [SMART App Launch Implementation Guide](http://hl7.org/fhir/smart-app-launch/1.0.0/).

Like SMART on FHIR, CDS Hooks requires that CDS Services present a valid access token to the FHIR server with each API call. Thus, a CDS Service requires an access token before communicating with the CDS Client's FHIR resource server. While CDS Hooks shares the underlying technical framework and standards as SMART on FHIR, the CDS Hooks workflow MUST accommodate the automated, low-latency delivery of an access token to the CDS service.

With CDS Hooks, if the CDS Client wants to provide the CDS Service direct access to FHIR resources, the CDS Client creates or obtains an access token prior to invoking the CDS Service, passing this token to the CDS Service as part of the service call. This approach remains compatible with [OAuth 2.0's](https://oauth.net/2/) bearer token protocol while minimizing the number of HTTPS round-trips and the service invocation latency. The CDS Client remains in control of providing an access token that is associated with the specific CDS Service, user, and context of the invocation.  As the CDS Service executes on behalf of a user, the data to which the CDS Service is given access by the CDS Client MUST be limited to the same restrictions and authorizations afforded the current user. As such, the access token SHALL be scoped to:

- The CDS Service being invoked
- The current user

#### Passing the Access Token to the CDS Service

The access token is specified in the CDS Service request via the `fhirAuthorization` request parameter. This parameter is an object that contains both the access token as well as other related information as specified below.  If the CDS Client chooses not to pass along an access token, the `fhirAuthorization` parameter is omitted.

Field | Optionality | Type | Description
----- | ----- | ----- | -----------
`access_token` | REQUIRED | *string* | This is the [OAuth 2.0](https://oauth.net/2/) access token that provides access to the FHIR server.
`token_type`   | REQUIRED | *string* | Fixed value: `Bearer`
`expires_in`   | REQUIRED | *integer* | The lifetime in seconds of the access token.
`scope`        | REQUIRED | *string* | The scopes the access token grants the CDS Service.
`subject` | REQUIRED | *string* | The [OAuth 2.0](https://oauth.net/2/) client identifier of the CDS Service, as registered with the CDS Client's authorization server.
'patient` | CONDITIONAL | *string* | If the granted SMART scopes include patient scopes (i.e. "patient/"), the access token is restricted to a specific patient. This field SHOULD be populated to identify the FHIR id of that patient.
{:.grid}

The scopes granted to the CDS Service via the `scope` field are defined by the [SMART on FHIR specification](http://hl7.org/fhir/smart-app-launch/1.0.0/scopes-and-launch-context/).

The `expires_in` value is established by the authorization server and SHOULD BE very short lived, as the access token MUST be treated as a transient value by the CDS Service. CDS Clients SHOULD revoke an issued access token upon the completion of the CDS Hooks request/response to limit the validity period of the token.

Below is an example `fhirAuthorization` parameter:

```json
{
  "fhirAuthorization": {
    "access_token": "some-opaque-fhir-access-token",
    "token_type": "Bearer",
    "expires_in": 300,
    "scope": "user/Patient.read user/Observation.read",
    "subject": "cds-service4"
  }
}
```

## CDS Service Response

For successful responses, CDS Services SHALL respond with a 200 HTTP response with an object containing a `cards` array and optionally a `systemActions` array as described below.

Each card contains decision support guidance from the CDS Service. Cards are intended for display to an end user. The data format of a card defines a very minimal set of required attributes with several more optional attributes to suit a variety of use cases, such as: narrative informational decision support, actionable suggestions to modify data, and links to SMART apps.


> Note that because the CDS client may be invoking multiple services from the same hook, there may be multiple responses related to the same information. This specification does not address these scenarios specifically; both CDS Services and CDS Clients should consider the implications of multiple CDS Services in their integrations and are invited to consider [card attributes](#card-attributes) when determining prioritization and presentation options.

### HTTP Status Codes

Code | Description
---- | -----------
`200 OK` | A successful response.
`412 Precondition Failed` | The CDS Service is unable to retrieve the necessary FHIR data to execute its decision support, either through a prefetch request or directly calling the FHIR server.
{:.grid}

CDS Services MAY return other HTTP statuses, specifically 4xx and 5xx HTTP error codes.

### HTTP Response

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`cards` | REQUIRED | *array* of **[Cards](#card-attributes)** | An array of **Cards**. Cards can provide a combination of information (for reading), suggested actions (to be applied if a user selects them), and links (to launch an app if the user selects them).  The CDS Client decides how to display cards, but this specification recommends displaying suggestions using buttons, and links using underlined text.
`systemActions` | OPTIONAL | *array* of **[Actions](#action)** |  An array of **Actions** that the CDS Service proposes to auto-apply. Each action follows the schema of a [card-based `suggestion.action`](#action). The CDS Client decides whether to auto-apply actions.
{:.grid}

If your CDS Service has no decision support for the user, your service should return a 200 HTTP response with an empty array of cards, for example:

```json
{
  "cards": []
}
```

Clients SHOULD remove `cards` returned by previous invocations of a `hook` to a service with the same `id` when a new `hook` is triggered (see [*update stale guidance*](security.html#update-stale-guidance)).

### Card Attributes

Each **Card** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`uuid` | OPTIONAL | *string* | Unique identifier of the card.  MAY be used for auditing and logging cards and SHALL be included in any subsequent calls to the CDS service's feedback endpoint.
`summary` | REQUIRED | *string* | One-sentence, <140-character summary message for display to the user inside of this card.
`detail` | OPTIONAL | *string* | Optional detailed information to display; if provided MUST be represented in [(GitHub Flavored) Markdown](https://github.github.com/gfm/). (For non-urgent cards, the CDS Client MAY hide these details until the user clicks a link like "view more details...").
`indicator` | REQUIRED | *string* | Urgency/importance of what this card conveys. Allowed values, in order of increasing urgency, are: `info`, `warning`, `critical`. The CDS Client MAY use this field to help make UI display decisions such as sort order or coloring.
`source` | REQUIRED | *object* | Grouping structure for the **[Source](#source)** of the information displayed on this card. The source should be the primary source of guidance for the decision support the card represents.
`suggestions` | OPTIONAL | *array* of **[Suggestions](#suggestion)** | Allows a service to suggest a set of changes in the context of the current activity (e.g.  changing the dose of a medication currently being prescribed, for the `order-sign` activity). If suggestions are present, `selectionBehavior` MUST also be provided.
`selectionBehavior` | CONDITIONAL | *string* | Describes the intended selection behavior of the suggestions in the card. Allowed values are: `at-most-one`, indicating that the user may choose none or at most one of the suggestions; `any`, indicating that the end user may choose any number of suggestions including none of them and all of them. CDS Clients that do not understand the value MUST treat the card as an error.
`overrideReasons` | OPTIONAL | *array* of **Coding** | Override reasons can be selected by the end user when overriding a card without taking the suggested recommendations. The CDS service MAY return a list of override reasons to the CDS client. If override reasons are present, the CDS Service MUST populate a `display` value for each reason's [Coding](extensions-datatypes.html#coding). The CDS Client SHOULD present these reasons to the clinician when they dismiss a card. A CDS Client MAY augment the override reasons presented to the user with its own reasons.
`links` | OPTIONAL | *array* of **[Links](#link)** | Allows a service to suggest a link to an app that the user might want to run for additional information or to help guide a decision.
{:.grid}

#### Source

The **Source** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`label`| REQUIRED | *string* | A short, human-readable label to display for the source of the information displayed on this card. If a `url` is also specified, this MAY be the text for the hyperlink.
`url` | OPTIONAL | *URL* | An optional absolute URL to load (via `GET`, in a browser context) when a user clicks on this link to learn more about the organization or data set that provided the information on this card. Note that this URL should not be used to supply a context-specific "drill-down" view of the information on this card. For that, use [card.link.url](#link) instead.
`icon` | OPTIONAL | *URL* | An absolute URL to an icon for the source of this card. The icon returned by this URL SHOULD be a 100x100 pixel PNG image without any transparent regions. The CDS Client may ignore or scale the image during display as appropriate for user experience.
`topic` | OPTIONAL | **[Coding](extensions-datatypes.html#coding)** | A *topic* describes the content of the card by providing a high-level categorization that can be useful for filtering, searching or ordered display of related cards in the CDS client's UI. This specification does not prescribe a standard set of topics.
{:.grid}

Below is an example `source` parameter:

```json
{
  "source": {
    "label": "Zika Virus Management",
    "url": "https://example.com/cdc-zika-virus-mgmt",
    "icon": "https://example.com/cdc-zika-virus-mgmt/100.png",
    "topic": {
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
`actions` | OPTIONAL | *array* of **[Actions](#action)** | Array of objects, each defining a suggested action. Within a suggestion, all actions are logically AND'd together, such that a user selecting a suggestion selects all of the actions within it. When a suggestion contains multiple actions, the actions SHOULD be processed as per FHIR's rules for processing [transactions](https://hl7.org/fhir/http.html#trules) with the CDS Client's `fhirServer` as the base url for the inferred full URL of the transaction bundle entries. (Specifically, deletes happen first, then creates, then updates).
{:.grid}

##### Action

Each **Action** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`type` |  REQUIRED | *string* | The type of action being performed. Allowed values are: `create`, `update`, `delete`.
`description` | REQUIRED | *string* | Human-readable description of the suggested action MAY be presented to the end-user.
`resource` | CONDITIONAL | *object* | A FHIR resource. When the `type` attribute is `create`, the `resource` attribute SHALL contain a new FHIR resource to be created.  For `update`, this holds the updated resource in its entirety and not just the changed fields. Use of this field to communicate a string of a FHIR id for delete suggestions is DEPRECATED and `resourceId` SHOULD be used instead.
`resourceId` | CONDITIONAL | *string* | A relative reference to the relevant resource. SHOULD be provided when the `type` attribute is `delete`.
{:.grid}

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

**overrideReasons** is an array of **[Coding](extensions-datatypes.html#coding)** that captures a codified set of reasons an end user may select from as the rejection reason when rejecting the advice presented in the card. When using the coding object to represent a reason, CDS Services MUST provide a human readable text in the *display* property and CDS Clients MAY incorporate it into their user interface.

This specification does not prescribe a standard set of override reasons; implementers are encouraged to submit suggestions for standardization.

```json
{
  "overrideReasons": [
    {
      "code": "reason-code-provided-by-service",
      "system": "http://example.org/cds-services/fhir/CodeSystem/override-reasons",
      "display": "Patient refused"
    },
    {
      "code": "12354",
      "system": "http://example.org/cds-services/fhir/CodeSystem/override-reasons",
      "display": "Contraindicated"
    }
  ]
}
```

#### Link

Each **Link** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`label`| REQUIRED | *string* | Human-readable label to display for this link (e.g. the CDS Client might render this as the underlined text of a clickable link).
`url` | REQUIRED | *URL* | URL to load (via `GET`, in a browser context) when a user clicks on this link. Note that this MAY be a "deep link" with context embedded in path segments, query parameters, or a hash.
`type` | REQUIRED | *string* | The type of the given URL. There are two possible values for this field. A type of `absolute` indicates that the URL is absolute and should be treated as-is. A type of `smart` indicates that the URL is a SMART app launch URL and the CDS Client should ensure the SMART app launch URL is populated with the appropriate SMART launch parameters.
`appContext` | OPTIONAL | *string* |  An optional field that allows the CDS Service to share information from the CDS card with a subsequently launched SMART app. The `appContext` field should only be valued if the link type is `smart` and is not valid for `absolute` links. The `appContext` field and value will be sent to the SMART app as part of the [OAuth 2.0](https://oauth.net/2/) access token response, alongside the other [SMART launch parameters](http://hl7.org/fhir/smart-app-launch/1.0.0/scopes-and-launch-context/#launch-context-arrives-with-your-access_token) when the SMART app is launched. Note that `appContext` could be escaped JSON, base64 encoded XML, or even a simple string, so long as the SMART app can recognize it. CDS Client support for `appContext` requires additional coordination with the authorization server that is not described or specified in CDS Hooks nor SMART.
`autolaunchable` | OPTIONAL | *boolean* |  This field serves as a hint to the CDS Client suggesting this link be immediately launched, without displaying the card and without manual user interaction.  Note that CDS Hooks cards which contain links with this field set to true, may not be shown to the user.  Sufficiently advanced CDS Clients may support automatically launching multiple links or multiple cards. Implementer guidance is requested to determine if the specification should preclude these advanced scenarios.
{:.grid}

##### Considerations for `autolaunchable` and user experience

The intent of this optional feature is to improve individual user experience by removing the otherwise unnecessary click of a link by the user. Appropriate support of this feature includes guardrails from both the CDS Service developer and the CDS Client, as well as additional local control by the organization using the service.

The CDS Client ultimately determines if a link can be automatically launched, taking into consideration user interface needs, workflow considerations, or even absence of support for this optional feature. If a CDS Hooks response contains guidance in addition to an autolaunchable link, it's the CDS Service's responsibility to ensure that any decision support that exists in the CDS Hooks response's card(s) is communicated via the launched app.

### System Action
A `systemAction` is the same **[Action](#action)** which may be returned in a suggestion, but is instead returned alongside the array of cards. A `systemAction` is not presented to the user within a card, but rather may be auto-applied without user intervention.

```json
{
  "cards": [],
  "systemActions": [
    {
      "type": "update",
      "resource": {
        "resourceType": "ServiceRequest",
        "id": "example-MRI-59879846",
        "...": "<snipped for brevity"
      }
    }
  ]
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
      },
      "overrideReasons": [
        {
          "code": "reason-code-provided-by-service",
          "system": "http://example.org/cds-services/fhir/CodeSystem/override-reasons",
          "display": "Patient refused"
        },
        {
          "code": "12354",
          "system": "http://example.org/cds-services/fhir/CodeSystem/override-reasons",
          "display": "Contraindicated"
        }
      ]
    }
  ]
}
```


> Example response using `autolaunchable`

```json
{
  "cards": [
    {
      "uuid": "4e0a3a1e-3283-4575-ab82-028d55fe2719",
      "summary": "Lung cancer screening shared decision making",
      "detail": "Patient is a current smoker with a 20 pack/year history. Consider advising patient to complete lung cancer screening. The Lung Cancer Screening Shared Decision Making App (LCSSDM) has been proven to increase patient followthrough for screening.",
      "source": {
        "label": "Lung Cancer Screening Shared Decision Making App",
        "url": "https://example.com/LCS",
        "icon": "https://example.com/img/icon-100px.png"
      },
      "links": [
        {
          "label": "Github",
          "url": "https://github.com",
          "type": "absolute",
          "autolaunchable": true
        }
      ]
    }
  ]
}
```

## Feedback

Once a CDS Hooks Service responds to a hook by returning a card, the service has no further interaction with the CDS Client. The acceptance of a suggestion or rejection of a card is valuable information to enable a service to improve its behavior towards the goal of the end-user having a positive and meaningful experience with the CDS. A feedback endpoint enables suggestion tracking & analytics. A CDS Service MAY support a feedback endpoint; a CDS Client SHOULD be capable of sending feedback.

Upon receiving a card, a user may accept its suggestions, ignore it entirely, or dismiss it with or without an override reason. Note that while one or more suggestions can be accepted, an entire card is either ignored or overridden.

Typically, an end user may only accept (a suggestion), or override a card once; however, a card once ignored could later be acted upon. CDS Hooks does not specify the UI behavior of CDS Clients, including the persistence of cards. CDS Clients should faithfully report each of these distinct end-user interactions as feedback.

A CDS Client provides feedback by POSTing a JSON document. The feedback endpoint can be constructed from the CDS Service endpoint and a path segment of "feedback"
as {baseUrl}/cds-services/{service.id}/feedback. The request to the feedback endpoint SHALL be an object containing an array.

Field | Description
----- | ------
`feedback` | *array* of **Feedback**
{:.grid}

Each **Feedback** SHALL be described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`card` | REQUIRED | *string* | The `card.uuid` from the CDS Hooks response. Uniquely identifies the card.
`outcome` | REQUIRED | *string* | A value of `accepted` or `overridden`.
`acceptedSuggestions` | CONDITIONAL | *array* | An array of json objects identifying one or more of the user's **AcceptedSuggestion**s. Required for `accepted` outcomes.
`overrideReason` | OPTIONAL | **[OverrideReason](#overridereason)** | A json object capturing the override reason as a **[Coding](extensions-datatypes.html#coding)** as well as any comments entered by the user.
`outcomeTimestamp` | REQUIRED | *string* | [ISO8601](https://en.wikipedia.org/wiki/ISO_8601) representation of the date and time in Coordinated Universal Time (UTC) when action was taken on the card, as profiled in [section 5.6 of RFC3339](https://datatracker.ietf.org/doc/html/rfc3339#section-5.6). e.g. 1985-04-12T23:20:50.52Z
{:.grid}


### Suggestion accepted

The CDS Client can inform the service when one or more suggestions were accepted by POSTing a simple JSON object. The CDS Client authenticates to the CDS service as described in [Trusting CDS Clients](security.html#trusting-cds-clients).

Upon the user accepting a suggestion (perhaps when she clicks a displayed label (e.g., button) from a "suggestion" card), the CDS Client informs the service by posting the card and suggestion `uuid`s to the CDS Service's feedback endpoint with an outcome of `accepted`.

To enable a positive clinical experience, the feedback endpoint may be called for multiple hook instances or multiple cards at the same time or even multiple times for a card or suggestion. Depending upon the UI and workflow of the CDS Client, a CDS Service may receive feedback for the same card instance multiple times.

Each **AcceptedSuggestion** is described by the following attributes.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`id` | REQUIRED | *string* | The `card.suggestion.uuid` from the CDS Hooks response. Uniquely identifies the suggestion that was accepted.
{:.grid}

#### Example suggestion accepted
```json

{
  "feedback": [
    {
      "card": "4e0a3a1e-3283-4575-ab82-028d55fe2719",
      "outcome": "accepted",
      "acceptedSuggestions": [
        {
          "id": "e56e1945-20b3-4393-8503-a1a20fd73152"
        }
      ],
      "outcomeTimestamp": "2021-12-11T10:05:31Z"
    }
  ]
}
```

If either the card or the suggestion has no `uuid`, the CDS Client does not send a notification.

### Card ignored

If the end-user doesn't interact with the CDS Service's card at all, the card is *ignored*. In this case, the CDS Client does not inform the CDS Service of the rejected guidance. Even with a `card.uuid`, a `suggestion.uuid`, and an available feedback service, the service is not informed (in part, because it may later be acted upon).

### Overridden guidance

A CDS Client may enable the end user to override guidance without providing an explicit reason for doing so. The CDS Client can inform the service when a card was dismissed by specifying an outcome of `overridden` without providing an `overrideReason`. This may occur, for example, when the end user viewed the card and dismissed it without providing a reason why.

#### Example overridden guidance without overrideReason

```json
POST {baseUrl}/cds-services/{serviceId}/feedback
{
  "feedback": [
    {
      "card": "f6b95768-b1c8-40dc-8385-bf3504b82ffb", // uuid from `card.uuid`
      "outcome": "overridden",
      "outcomeTimestamp": "2020-12-11T00:00:00Z"
    }
  ]
}
```

### Explicit reject with override reasons

A CDS Client can inform the service when a card was rejected by POSTing an outcome of `overridden` along with an `overrideReason` to the service's feedback endpoint. The CDS Client may enable the clinician to provide an additional `overrideReason` or to supplement the `overrideReason` with a free text comment, supplied to the CDS Service in `overrideReason.userComment`.

#### OverrideReason

Each **OverrideReason** is described by the following attributes, in the feedback POST to the CDS Service.

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`reason` | CONDITIONAL |**[Coding](extensions-datatypes.html#coding)** | The Coding object representing the override reason selected by the end user. Required if user selected an override reason from the list of reasons provided in the Card (instead of only leaving a userComment).
`userComment` | OPTIONAL | *string* | The CDS Client may enable the clinician to further explain why the card was rejected with free text. That user comment may be communicated to the CDS Service as a `userComment`.
{:.grid}

#### Example overridden guidance with overrideReason

```json
POST {baseUrl}/cds-services/{serviceId}/feedback

{
   "feedback":[
      {
         "card":"9368d37b-283f-44a0-93ea-547cebab93ed",
         "outcome":"overridden",
         "overrideReason":{
            "reason":{
               "code":"d7ecf885",
               "system":"https://example.com/cds-hooks/override-reason-system"
            },
            "userComment":"A comment entered by the clinician."
         },
         "outcomeTimestamp":"2020-12-11T00:00:00Z"
      }
   ]
}
```
