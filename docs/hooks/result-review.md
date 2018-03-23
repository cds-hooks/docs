# `result-review`

## Workflow description

The user is in the process of reviewing a set of results.

## Context

The user reviewing the lab results. All FHIR resources in this context MUST be based on the same FHIR version.

Field         | Priority | Prefetch Token | Description
------------- | -------- | -------------- | ----------------------------------------------------------------------------
`patientId`   | REQUIRED | Yes            | _string_. The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes            | _string_. The FHIR `Encounter.id` of the current encounter in context
`results`     | REQUIRED | No             | _array_ DSTU2 - Array of Observation<br> _array_ STU3 - Array of Observation

### Example (STU3)

```json
"context":{
  "patientId" : "1288992",
  "encounterId" : "89284",
  "results":[  
    {
    "resourceType": "Observation",
    "id": "f204",
    "identifier": [
          {
            "system": "https://intranet.aumc.nl/labvalues",
            "value": "1304-03720-Creatinine"
          }
        ],
        "status": "final",
        "code": {
          "coding": [
            {
              "system": "https://intranet.aumc.nl/labtestcodes",
              "code": "20005",
              "display": "Creatinine(Serum)"
            }
          ]
        },
        "subject": {
          "reference": "Patient/1288992",
        },
        "issued": "2013-04-04T14:34:00+01:00",
        "performer": [
          {
            "reference": "Practitioner/f202",
            "display": "Luigi Maas"
          }
        ],
        "valueQuantity": {
          "value": 122,
          "unit": "umol/L",
          "system": "http://snomed.info/sct",
          "code": "258814008"
        },
        "interpretation": {
          "coding": [
            {
              "system": "http://snomed.info/sct",
              "code": "166717003",
              "display": "Serum creatinine raised"
            },
            {
              "system": "http://hl7.org/fhir/v2/0078",
              "code": "H"
            }
          ]
        },
        "referenceRange": [
          {
            "low": {
              "value": 64
            },
            "high": {
              "value": 104
            },
            "type": {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/referencerange-meaning",
                  "code": "normal",
                  "display": "Normal Range"
                }
              ]
            }
          }
        ]
      }
  ]
}
```
