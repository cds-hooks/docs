# Prefetch

## A performance tweak

If real-world performance were no issue, an EHR could launch a CDS Service
passing only *context* data, and *without passing any additional clinical data*
up-front. The CDS Service could then request any data it needed via the EHR's
FHIR REST API.

But CDS services must respond quickly (on the order of 500 ms), and so we
provide a performance tweak that allows a CDS Service to register a set of "prefetch
templates" with the EHR ahead of time.

The prefetch templates are a dictionary of `read` and `search` requests to supply
relevant data, where the following variables are defined:

|variable|meaning|
---------|--------
|`{{Patient.id}}`|The id of the patient in context for this activity (e.g. `123`)|
|`{{User.id}}`|The type and id of the user for this session (e.g. `Practitioner/123`)|

An EHR *may* choose to honor some or all of the desired prefetch templates from an appropriate source. For example:

- The EHR may have some of the desired prefetched data already in memory, thereby removing the need for any network call
- The EHR may compute an efficient set of prefetch templates from multiple CDS Services, thereby reducing the number of network calls to a minimum
- The EHR may satisfy some of the desired prefetched templates via some internal service or even its own FHIR server

Regardless of how the EHR satisfies the prefetched templates (if at all), it is important that the prefetched data given to the CDS Service is equivalent to the CDS Service making its own call to the EHR FHIR server, where `{{Patient.id}}` is replaced with the id of the current patient (e.g. `123`) inside of any URL strings and using `read` and `search` operations to the server's "transaction" endpoint as a FHIR batch-type bundle.

The resulting response, which must be rendered in a single page — no "next
page" links allowed — is passed along to the CDS Service using the
`prefetch` parameter (see below for a complete example). 

The CDS Service must not receive any prefetch template key that the EHR chooses not to satisfy. Additionally, if the EHR encounters an error while retrieving any prefetched data, the prefetch template key should not be sent to the CDS Service. It is the CDS Service's responsibility to check to see what prefetched data was satisfied (if any) and manually retrieve any necessary data.

## Example prefetch request

```json
{
  "prefetch": {
    "p": "Patient/{{Patient.id}}",
    "a1c": "Observation?patient={{Patient.id}}&code=4548-4&_count=1&sort:desc=date",
    "u": "Practitioner/{{User.id}}"
  }
}
```

Here is an example prefetch property from a CDS service discovery endpoint. The
goal is to know, at call time:

| Key | Description |
| --- | ----------- |
| `p` | Patient demographics |
| `a1c` | Most recent Hemoglobin A1c reading for this patient |
| `u` | Information on the current user (Practitioner)

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

Note that the missing `u` key indicates that either the EHR has decided not to satisfy this particular prefetch template or it was not able to retrieve this prefetched data. The CDS Service is responsible for retrieving this Practitioner data from the FHIR server (if required).

## Prefetch query restrictions

To reduce the implementation burden on EHRs that support CDS services, CDS Hooks recommends that prefetch queries only use a subset of the full functionality available in the FHIR specification. Valid prefetch URLs should only contain:

* _instance_ level [read](https://www.hl7.org/fhir/http.html#read) interactions (for resources with known ids such as `Patient` and `Practitioner`)
* _type_ level [search](https://www.hl7.org/fhir/http.html#search) interactions
* Patient references (e.g. `patient={{Patient}}`)
* _token_ search parameters using equality (e.g. `code=4548-4`) and optionally the `:in` modifier (no other modifiers for token parameters)
* _date_ search parameters on `date`, `dateTime`, `instant`, or `Period` types only, and using only the prefixes `eq`, `lt`, `gt`, `ge`, `le`
* the `_count` parameter to limit the number of results returned
* the `_sort` parameter to allow for _most recent_ and _first_ queries

