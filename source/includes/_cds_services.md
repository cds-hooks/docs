# CDS Services

## Discovery

```shell
curl "https://example.com/.well-known/cds-services"
```

> The above command returns JSON structured like this:

```json
{
  "services": [
    {
      "hook": "patient-view",
      "name": "Static CDS Service Example",
      "description": "An example of a CDS service that returns a static set of cards",
      "id": "static-patient-greeter",
      "prefetch": {
        "patientToGreet": "Patient/{{Patient.id}}"
      }
    },
    {
      "hook": "medication-prescribe",
      "name": "Medication Echo CDS Service",
      "description": "An example of a CDS service that simply echos the medication being prescribed",
      "id": "medication-echo",
      "prefetch": {
        "patient": "Patient/{{Patient.id}}",
        "medications": "MedicationOrder?patient={{Patient.id}}"
      }
    }
  ]
}
```

Developers of CDS Services must provide a well-known endpoint allowing the EHR to discover all available CDS Services, including information such as the purpose of the CDS Service, when it should be invoked, and any data that is requested to be prefetched.

### HTTP Request

The discovery endpoint is always available at `{baseUrl}/.well-known/cds-services`. For example, if the `baseUrl` is https://example.com, the EHR would invoke:

`GET https://example.com/.well-known/cds-services`

<aside class="notice">
The URI path prefix of /.well-known/ is defined by <a href="https://tools.ietf.org/html/rfc5785">RFC 5785</a> for the sole purpose of expressing static, well-known URLs.
</aside>

## Calling a CDS Service

```shell
{
  hookInstannce:          1..1,
  hook:                   1..1,
  fhirServer:             0..1,
  oauth:                  0..1 {
    token:                1..1,
    scope:                1..1,
    expires:              1..1
  },
  redirect:               1..1,
  user:                   0..1,
  patient:                0..1,
  encounter:              0..1,
  context:                0..* resource(Any),
  prefetch:               0..1 { }
}
```


```
curl "https://example.com/cds-services/static-patient-greeter"
```

```json
{
   "hookInstance" : "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
   "fhirServer" : "http://hooks.smarthealthit.org:9080",
   "hook" : "patient-view",
   "redirect" : "http://hooks2.smarthealthit.org/service-done.html",
   "user" : "Practitioner/example",
   "context" : [],
   "patient" : "1288992",
   "prefetch" : {
      "patientToGreet" : {
         "response" : {
            "status" : "200 OK"
         },
         "resource" : {
            "resourceType" : "Patient",
            "gender" : "male",
            "birthDate" : "1925-12-23",
            "id" : "1288992",
            "active" : true
         }
      }
   }
}
```

### Request fields

The CDS Hook call includes the following input fields:

**`hook`** name of the hook (a string or URL) that the user has triggered in the EHR (e.g. `patient-view`, or `medication-prescribe`).

**`hookInstance`** While working in the EHR, a user can perform
multiple activities in series or in parallel. For example, a clinician might prescribe
two drugs in a row; each prescription activity would be assigned a
unique `hookInstance`. The [[activity catalog|Activity]]
provides a description of what events should initiate and terminate
a given hook. This allows an external
service to associate requests with activity state, which is necessary to
support the following app-centric decision sequence, where
the steps are tied together by a common `hookInstance`:

  0. EHR invokes CDS hook
  1. CDS service returns *app link card*
  2. User clicks app link and interacts with app
  3. Flow returns to EHR, which re-invokes CDS hook
  4. CDS service returns *decision* with user's choice

Note: the `hookInstance` is globally unique and should contain enough entropy
to be un-guessable.

**`fhirServer`** Base URL for the calling EHR's FHIR server. The scheme should
be `https`.

**`oauth`** Security details allowing the CDS service to connect to the EHR's
FHIR server.  These fields allow the CDS service to access EHR data in a
context limited by the current user's privileges. `expires` expresses the
token lifetime as an integer number of seconds. `scope` represents the set of
scopes assigned to this token (see [SMART on FHIR
scopes](http://docs.smarthealthit.org/authorization/scopes-and-launch-context/)).
Finally, `token` is a bearer token to be presented with any API calls the CDS
service makes to the EHR, by including it in an Authorization header like:

    `Authorization: Bearer {{token}}`

**`redirect`** This field is only used by services that will return an *app
link card*: when a user clicks the card's link to launch an app, it becomes
the app's job to send the user to *this `redirect` URL* upon completion of
user interaction. (*Design note*: this field is supplied up-front, as part of
the initial request, to avoid requiring the EHR to append any content to app
launch links. This helps support an important "degenerate" use case for app
link cards: pointing to static content. See below for details.)

**`user`** The  FHIR resource type + id representing the current user. For
example, `Practitioner/123`. The type is one of: `Practitioner`, `Patient`, or
`RelatedPerson`.

**`patient`** The  FHIR resource id of the current patient. For example,
`123`.

**`encounter`** The  FHIR resource id of the current encounter.  For example,
`123`.

**`context`** activity-specific contextual data (see [[Activity]]) that an external service
needs. (For exampe, with the `order-review` activity this will include
MedicationOrder and  Diagnostic resources, among others)

**`prefetch`** as a performance tweak, the EHR may pass along data according
to the service's [[Prefetch-Template]]. This helps provide the service with all
the data it needs to efficiently compute a set of recommendations. Each key matches a key described in the CDS Service Discovery document; and each value is a FHIR Bundle.entry indicating a response status and returned resource.

Note that in the absence of `prefetch`, an external service can always execute
FHIR REST API calls against the EHR server to obtain additional data ad-hoc.)
An EHR calls a CDS service by `POST`ing a JSON document to the service
endpoint, which can be constructed from the CDS Service base URL and an
individual serviec id as `{baseUrl}/cds-services/{service.id}`.

See details
about the data model [in
swagger](http://editor.swagger.io/#/?import=https://raw.githubusercontent.com/cds-hooks/api/master/cds-hooks.yaml?token=AATHAQY8vqQ6dIZajRuuE55EWMBitTptks5XLMk6wA%3D%3D)



## CDS Service Response


```json
{
  "cards": [
    {
      "summary": "Success Card",
      "indicator": "success",
      "detail": "This is an example success card.",
      "source": {
        "name": "Static CDS Service Example",
        "url": "https://example.com"
      },
      "links": [
        {
          "label": "Google",
          "url": "https://google.com"
        },
        {
          "label": "Github",
          "url": "https://github.com"
        }
      ]
    },
    {
      "summary": "Info card",
      "indicator": "info",
      "source": {
        "name": "Static CDS Service Example"
      }
    }
  ]
}
```
This command returns JSON structured like:
