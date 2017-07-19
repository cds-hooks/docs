# Prefetch

## A performance tweak

If real-world performance were no issue, an EHR could launch a CDS Service
passing only *context* data, and *without passing any additional clinical data*
up-front. The CDS Service could then request any data it needed via the EHR's
FHIR REST API.

But CDS services must respond quickly (on the order of 500 ms), and so we
provide a performance tweak that allows an app to register a set of "prefetch
templates" with the EHR ahead of time.

The prefetch templates are a dictionary `read` and `search` requests to supply
relevant data, where the following variables are defined:

|variable|meaning|
---------|--------
|`{{Patient.id}}`|The id of the patient in context for this activity (e.g. `123`)|
|`{{User.id}}`|The type and id of the user for this session (e.g. `Practitioner/123`)|

Before calling the CDS Service, the EHR will fill out this template, replacing
`{{Patient.id}}` with the id of the current patient (e.g. `123`) inside of any
URL strings. The EHR then executes the requests in the template as a set of
FHIR `read` and `search` operations (exactly as though they had been submitted
to the server's "transaction" endpoint as a FHIR batch-type bundle).

The resulting response, which must be rendered in a single page — no "next
page" links allowed — is passed along to the CDS Service using the
`prefetch` parameter (see below for a complete example).

## Example prefetch request

```json
{
  "prefetch": {
    "p": "Patient/{{Patient.id}}",
    "a1c": "Observation?patient={{Patient.id}}&code=4548-4&_count=1&sort:desc=date"
  }
}
```


Here is an example prefetch property from a CDS service discovery endpoint. The
goal is to know, at call time:

 * Patient demographics
 * Most recent Hemoglobin A1c reading for this patient

## Example prefetch response

```json
{
  "prefetch": {
    "p":{
      "response": {
        "status": "200 OK"
      },
      "resource": {
        "resourceType": "Patient",
        "gender": "male",
        "birthDate": "1974-12-25",
        "...": "<snipped for brevity>"
      }
    },
    "a1c": {
      "response": {
        "status": "200 OK"
      },
      "resource":{
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
}
```

The response is augmented to include two prefetch values, where the dictionary
keys match the request keys (`p` and `a1c` in this case).

Note that a missing key indicates that an EHR has not attempted to supply a
given prefetch value; the CDS service can issue the request manually at call
time to fetch the required data.``

## Prefetch query restrictions

To reduce the implementation burden on EHRs that support CDS services, CDS Hooks requires that prefetch queries only use a subset of the full functionality available in the FHIR specification. Valid prefetch URLs are only allowed to contain:

* _instance_ level read interactions (for the `Patient` resource only)
* _type_ level search interactions (using `GET`)
* Patient references (e.g. `patient={{Patient}}`)
* _token_ search parameters using equality (e.g. `code=4548-4`) and optionally the `:in` modifier (no other modifiers for token parameters are allowed)
* _date_ search parameters on `date`, `dateTime`, `instant`, or `Period` types only, and using only the prefixes `eq`, `lt`, `gt`, `ge`, `le`
* the `_count` parameter to limit the number of results returned
* the `_sort` parameter to allow for _most recent_ and _first_ queries

