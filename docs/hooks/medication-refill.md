# `medication-refill`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 0.1.0

## Workflow

The `medication-refill` hook fires when a medication refill is requested for an existing prescription of a specific medication. A refill request may be made as part of an encounter or out-of-band through a pharmacy. There may not be either an encounter or user in context when the refill request is received.  A CDS service may use this hook to deliver medication refill protocol guidance to a clinician.

## Context

The set of medications proposed or in progress of being prescribed. All FHIR resources in this context MUST be based on the same FHIR version. All FHIR resources in the medications object MUST have a status of _draft_.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | OPTIONAL | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html).<br />For example, `Practitioner/123`
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* |  The FHIR `Encounter.id` of the current encounter in context
`medications` | REQUIRED | No | *object* | DSTU2 - FHIR Bundle of _draft_ MedicationOrder resources <br/> STU3 - FHIR Bundle of _draft_ MedicationRequest resources

### Example (STU3)

```json
{
   "context":{
      "userId":"Practitioner/123",
      "patientId":"1288992",
      "encounterId":"89284",
      "medications":{
         "resourceType":"Bundle",
         "entry":[
            {
               "resource":{
                  "resourceType":"MedicationRequest",
                  "id":"smart-MedicationRequest-104",
                  "status":"draft",
                  "intent":"order",
                  "medicationCodeableConcept":{
                     "coding":[
                        {
                           "system":"http://www.nlm.nih.gov/research/umls/rxnorm",
                           "code":"211307",
                           "display":"Azithromycin 20 MG/ML Oral Suspension [Zithromax]"
                        }
                     ],
                     "text":"Azithromycin 20 MG/ML Oral Suspension [Zithromax]"
                  },
                  "subject":{
                     "reference":"Patient/1288992"
                  },
                  "dosageInstruction":[
                     {
                        "text":"15 mL daily x 3 days",
                        "timing":{
                           "repeat":{
                              "boundsPeriod":{
                                 "start":"2005-01-18"
                              },
                              "frequency":1,
                              "period":1,
                              "periodUnit":"d"
                           }
                        },
                        "doseQuantity":{
                           "value":15,
                           "unit":"mL",
                           "system":"http://unitsofmeasure.org",
                           "code":"mL"
                        }
                     }
                  ],
                  "dispenseRequest":{
                     "numberOfRepeatsAllowed":1,
                     "quantity":{
                        "value":1,
                        "unit":"mL",
                        "system":"http://unitsofmeasure.org",
                        "code":"mL"
                     },
                     "expectedSupplyDuration":{
                        "value":3,
                        "unit":"days",
                        "system":"http://unitsofmeasure.org",
                        "code":"d"
                     }
                  }
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
      "medications":{
         "resourceType":"Bundle",
         "entry":[
            {
               "resource":{
                  "resourceType":"MedicationOrder",
                  "id":"smart-MedicationOrder-104",
                  "status":"draft",
                  "patient":{
                     "reference":"Patient/1288992"
                  },
                  "medicationCodeableConcept":{
                     "coding":[
                        {
                           "system":"http://www.nlm.nih.gov/research/umls/rxnorm",
                           "code":"211307",
                           "display":"Azithromycin 20 MG/ML Oral Suspension [Zithromax]"
                        }
                     ],
                     "text":"Azithromycin 20 MG/ML Oral Suspension [Zithromax]"
                  },
                  "dosageInstruction":[
                     {
                        "text":"15 mL daily x 3 days",
                        "timing":{
                           "repeat":{
                              "boundsPeriod":{
                                 "start":"2005-01-18"
                              },
                              "frequency":1,
                              "period":1,
                              "periodUnits":"d"
                           }
                        },
                        "doseQuantity":{
                           "value":15,
                           "unit":"mL",
                           "system":"http://unitsofmeasure.org",
                           "code":"mL"
                        }
                     }
                  ],
                  "dispenseRequest":{
                     "numberOfRepeatsAllowed":1,
                     "quantity":{
                        "value":1,
                        "unit":"mL",
                        "system":"http://unitsofmeasure.org",
                        "code":"mL"
                     },
                     "expectedSupplyDuration":{
                        "value":3,
                        "unit":"days",
                        "system":"http://unitsofmeasure.org",
                        "code":"d"
                     }
                  }
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
