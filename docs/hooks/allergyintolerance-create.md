# `allergyintolerance-create`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 0.1.0

## Workflow

The `allergyintolerance-create` hook fires when when a clinician adds one or more new allergies or intolerances to a patient's list of allergies. 
This hook may fire with one or more newly added, active allergies or draft allergies that are not yet finalized. 
The context of the hook includes these new AllergyIntolerances.

## Context

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html).<br />For example, `Practitioner/123`
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* |  The FHIR `Encounter.id` of the current encounter in context
`allergyIntolerances` | REQUIRED | No | *object* | DSTU2 - FHIR Bundle of AllergyIntolerance<br/> STU3 - FHIR Bundle of AllergyIntolerance


### Examples

### Example (STU3)

```json
{
   "context":{
      "userId":"Practitioner/123",
      "patientId":"1288992",
      "encounterId":"89284",
      "allergyIntolerances":{
         "resourceType":"Bundle",
         "entry":[
            {
               "resource":{
                  "resourceType":"AllergyIntolerance",
                  "id":"RES163672",
                  "clinicalStatus":"active",
                  "verificationStatus":"confirmed",
                  "type":"allergy",
                  "category":[
                     "food"
                  ],
                  "criticality":"high",
                  "code":{
                     "coding":[
                        {
                           "system":"http://snomed.info/sct",
                           "code":"424213003",
                           "display":"Allergy to bee venom"
                        }
                     ]
                  },
                  "patient":{
                     "reference":"Patient/1288992"
                  },
                  "assertedDate":"2018-11-15T07:05:57-05:00"
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
   "context":{
      "userId":"Practitioner/123",
      "patientId":"1288992",
      "encounterId":"89284",
      "allergyIntolerances":{
         "resourceType":"Bundle",
         "entry":[
            {
               "resource":{
                  "resourceType":"AllergyIntolerance",
                  "id":"RES443610",
                  "recordedDate":"1992-05-28T17:22:05-04:00",
                  "patient":{
                     "reference":"Patient/1288992"
                  },
                  "substance":{
                     "coding":[
                        {
                           "system":"http://snomed.info/sct",
                           "code":"424213003",
                           "display":"Allergy to bee venom"
                        }
                     ]
                  },
                  "status":"active",
                  "criticality":"low",
                  "type":"allergy",
                  "category":"food"
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
