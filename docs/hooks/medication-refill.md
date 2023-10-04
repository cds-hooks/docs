# `medication-refill`

| Metadata | Value
| ---- | ----
| specificationVersion | 2.0
| hookVersion | 0.1.0

## Workflow

The `medication-refill` hook fires when a medication refill request for an existing prescription of a specific medication is received. A refill request may be made as part of an encounter or out-of-band through a pharmacy or patient portal. Since a prescription refill is requested outside of the prescriber's workflow, there often is not a user in context. Similarly, the encounter may be an auto-generated refill encounter or there may not be an encounter in context when the refill request is received.  A CDS service may use this hook to deliver medication refill protocol guidance to a clinician. Given the asynchronous workflow of refill requests, the guidance returned by the service may be viewed immediately, or not.

This hook does not fire for an initial prescription (see order-sign). "Re-prescribing" or replacing a previously active prescription with a new perscription for the same medication does not fire the medication-refill.

## Context

The set of medications in the process of being refilled. All FHIR resources in this context MUST be based on the same FHIR version. All FHIR resources in the medications object MUST have a status of _draft_.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | OPTIONAL | Yes | *string* | In the case when this field is empty, consider the FHIR resource's requestor and recorder elements. <br />The id of the current user entering the refill request within the CPOE. For this hook, the user is expected to be of type Practitioner or PractitionerRole. For example, PractitionerRole/123 or Practitioner/abc.
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* |  The FHIR `Encounter.id` of the encounter associated with the refill of the prescription. 
`medications` | REQUIRED | No | *object* | R4 - FHIR Bundle of _draft_, _order_ MedicationRequest resources

### Example (R4)

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
                  "medicationReference": {
                     "reference": "Medication/eFnx9hyX.YTNJ407PR9g4zpiT8lXCElOXkldLgGDYrAU-fszvYmrUZlYzRfJl-qKj3",
                     "display": "oxybutynin (DITROPAN XL) CR tablet"
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
