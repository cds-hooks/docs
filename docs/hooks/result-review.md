# `result-review`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0

## Workflow 

The user is in the process of reviewing a set of results.

## Context

The user reviewing the lab results. All FHIR resources in this context MUST be based on the same FHIR version.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`patientId` | REQUIRED | Yes | *string* | The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* | The FHIR `Encounter.id` of the current encounter in context
`results`     | REQUIRED | No  | _object_ | DSTU2 - FHIR Bundle of Observation<br> STU3 - FHIR Bundle of Observation

### Example (STU3)

```json
"context":{
  "patientId": "1288992",
  "encounterId": "89284",
  "results": {
    "resourceType": "Bundle",
    "entry": [
      {
        "resourceType": "Observation",
        "id": "171184",
        "meta": {
          "versionId": "2",
          "lastUpdated": "2018-03-28T21:35:28.000+00:00"
        },
        "status": "final",
        "category": {
          "coding": [
            {
              "system": "http://hl7.org/fhir/observation-category",
              "code": "laboratory",
              "display": "Laboratory"
            }
          ],
          "text": "Laboratory"
        },
        "code": {
          "coding": [
            {
              "system": "http://loinc.org",
              "code": "2951-2",
              "display": "Sodium [Moles/volume] in Serum or Plasma"
            }
          ],
          "text": "Sodium"
        },
        "subject": {
          "reference": "Patient/171092"
        },
        "effectiveDateTime": "2018-03-28T04:00:00.000Z",
        "valueQuantity": {
          "value": 130,
          "unit": "mmol/L",
          "system": "http://unitsofmeasure.org",
          "code": "mmol/L"
        },
        "interpretation": {
          "coding": [
            {
              "system": "http://hl7.org/fhir/ValueSet/observation-interpretation",
              "code": "L",
              "display": "Low"
            }
          ],
          "text": "L"
        }
      }
    ]
  }
}
```
