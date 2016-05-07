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
        "patient": "Patient/{{Patient.id}}"
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

## Invocation

An EHR calls a CDS service by `POST`ing a JSON document to the service
endpoint, which can be constructed from the CDS Service base URL and an individual serviec id as `{baseUrl}/cds-services/{service.id}`. See details about the data model [in
swagger](http://editor.swagger.io/#/?import=https://raw.githubusercontent.com/cds-hooks/api/master/cds-hooks.yaml?token=AATHAQY8vqQ6dIZajRuuE55EWMBitTptks5XLMk6wA%3D%3D)


```shell
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


> The above command returns JSON structured like this:

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
