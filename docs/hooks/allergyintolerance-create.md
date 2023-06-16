# `allergyintolerance-create`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 0.1.0
| hookMaturity | 1 - Submitted

## Workflow

The `allergyintolerance-create` hook fires when when a clinician adds a new allergy or intolerance to a patient's list of allergies. 
This hook fires during the act of finalizing the entry of a new allergy, such that the decision support returned from the CDS Service can guide the clinician to cancel the addition of the allergy. The context of the hook include the AllergyIntolerance resource that's about to be added to the patient's list of allergies. 

## Context

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html).<br />For example, `Practitioner/123`
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* |  The FHIR `Encounter.id` of the current encounter in context
`allergyIntolerance` | REQUIRED | No | *object* | R4/STU3/DSTU2 - FHIR AllergyIntolerance isntance


### Examples

### Example (R4)

```json
{
  "context": {
    "userId": "Practitioner/123",
    "patientId": "1288992",
    "encounterId": "89284",
    "allergyIntolerance": {
      "resource": {
        "resourceType": "AllergyIntolerance",
        "id": "RES163672",
        "clinicalStatus": "active",
        "verificationStatus": "confirmed",
        "type": "allergy",
        "category": [
          "food"
        ],
        "criticality": "high",
        "code": {
          "coding": [
            {
              "system": "http://snomed.info/sct",
              "code": "424213003",
              "display": "Allergy to bee venom"
            }
          ]
        },
        "patient": {
          "reference": "Patient/1288992"
        },
        "assertedDate": "2018-11-15T07:05:57-05:00"
      }
    }
  }
}
```


### Example (STU3)

```json
{
  "context": {
    "userId": "Practitioner/123",
    "patientId": "1288992",
    "encounterId": "89284",
    "allergyIntolerances": {
      "resourceType": "Bundle",
      "entry": [
        {
          "resource": {
            "resourceType": "AllergyIntolerance",
            "id": "RES163672",
            "clinicalStatus": "active",
            "verificationStatus": "confirmed",
            "type": "allergy",
            "category": [
              "food"
            ],
            "criticality": "high",
            "code": {
              "coding": [
                {
                  "system": "http://snomed.info/sct",
                  "code": "424213003",
                  "display": "Allergy to bee venom"
                }
              ]
            },
            "patient": {
              "reference": "Patient/1288992"
            },
            "assertedDate": "2018-11-15T07:05:57-05:00"
          }
        }
      ]
    }
  }
}
```

### Example (DSTU2)
 
```json
{
  "context": {
    "userId": "Practitioner/123",
    "patientId": "1288992",
    "encounterId": "89284",
    "allergyIntolerances": {
      "resourceType": "Bundle",
      "entry": [
        {
          "resource": {
            "resourceType": "AllergyIntolerance",
            "id": "RES443610",
            "recordedDate": "1992-05-28T17:22:05-04:00",
            "patient": {
              "reference": "Patient/1288992"
            },
            "substance": {
              "coding": [
                {
                  "system": "http://snomed.info/sct",
                  "code": "424213003",
                  "display": "Allergy to bee venom"
                }
              ]
            },
            "status": "active",
            "criticality": "low",
            "type": "allergy",
            "category": "food"
          }
        }
      ]
    }
  }
}
```

## Change Log

Version | Description
---- | ----
0.1.0 | Initial Release
