# `order-review`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0
| Hook maturity | [3 - Considered](../../specification/1.0/#hook-maturity-model)

## Deprecation Notice

This hook is deprecated in favor of the `order-sign` hooks, with the goal of  clarifying workflow trigger points and supporting orders beyond medications. In this refactoring, `medication-prescribe` and `order-review` hooks are being deprecated in favor of newly created [`order-select`](../order-select) and [`order-sign`](../order-sign) hooks. This notice is a placeholder to this effect while CDS Hooks determines the [appropriate process for deprecating hooks](https://github.com/cds-hooks/docs/issues/433).

## Workflow

The user is in the process of reviewing a set of orders to sign.

## Context

The set of orders being reviewed for signature on-screen. All FHIR resources in this _context_ MUST be based on the same FHIR version. All FHIR resources in the `orders` object MUST have a status of _draft_.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html).<br />For example, `Practitioner/123`
`patientId` | REQUIRED | Yes | *string* | The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* | The FHIR `Encounter.id` of the current encounter in context
`orders` | REQUIRED | No | *object* | DSTU2 - FHIR Bundle of MedicationOrder, DiagnosticOrder, DeviceUseRequest, ReferralRequest, ProcedureRequest, NutritionOrder, VisionPrescription with _draft_ status <br/> STU3 - FHIR Bundle of MedicationRequest, ReferralRequest, ProcedureRequest, NutritionOrder, VisionPrescription with _draft_ status

### Example (STU3)

```json
{
   "context":{
      "userId":"Practitioner/123",
      "patientId":"1288992",
      "encounterId":"89284",
      "orders":{
         "resourceType":"Bundle",
         "entry":[
            {
               "resource":{
                  "resourceType":"NutritionOrder",
                  "id":"pureeddiet-simple",
                  "identifier":[
                     {
                        "system":"http://goodhealthhospital.org/nutrition-requests",
                        "value":"123"
                     }
                  ],
                  "status":"draft",
                  "patient":{
                     "reference":"Patient/1288992"
                  },
                  "dateTime":"2014-09-17",
                  "orderer":{
                     "reference":"Practitioner/example",
                     "display":"Dr Adam Careful"
                  },
                  "oralDiet":{
                     "type":[
                        {
                           "coding":[
                              {
                                 "system":"http://snomed.info/sct",
                                 "code":"226211001",
                                 "display":"Pureed diet"
                              },
                              {
                                 "system":"http://goodhealthhospital.org/diet-type-codes",
                                 "code":"1010",
                                 "display":"Pureed diet"
                              }
                           ],
                           "text":"Pureed diet"
                        }
                     ],
                     "schedule":[
                        {
                           "repeat":{
                              "boundsPeriod":{
                                 "start":"2015-02-10"
                              },
                              "frequency":3,
                              "period":1,
                              "periodUnit":"d"
                           }
                        }
                     ],
                     "texture":[
                        {
                           "modifier":{
                              "coding":[
                                 {
                                    "system":"http://snomed.info/sct",
                                    "code":"228055009",
                                    "display":"Liquidized food"
                                 }
                              ],
                              "text":"Pureed"
                           }
                        }
                     ],
                     "fluidConsistencyType":[
                        {
                           "coding":[
                              {
                                 "system":"http://snomed.info/sct",
                                 "code":"439021000124105",
                                 "display":"Dietary liquid consistency - nectar thick liquid"
                              }
                           ],
                           "text":"Nectar thick liquids"
                        }
                     ]
                  },
                  "supplement":[
                     {
                        "type":{
                           "coding":[
                              {
                                 "system":"http://snomed.info/sct",
                                 "code":"442971000124100",
                                 "display":"Adult high energy formula"
                              },
                              {
                                 "system":"http://goodhealthhospital.org/supplement-type-codes",
                                 "code":"1040",
                                 "display":"Adult high energy pudding"
                              }
                           ],
                           "text":"Adult high energy pudding"
                        },
                        "productName":"Ensure Pudding 4 oz container",
                        "instruction":"Ensure Pudding at breakfast, lunch, supper"
                     }
                  ]
               }
            },
            {
               "resource":{
                  "resourceType":"MedicationRequest",
                  "id":"smart-MedicationRequest-103",
                  "meta":{
                     "lastUpdated":"2018-04-30T13:25:40.845-04:00"
                  },
                  "text":{
                     "status":"generated",
                     "div":"<div xmlns=\"http://www.w3.org/1999/xhtml\">Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension (rxnorm: 617993)</div>"
                  },
                  "status":"draft",
                  "intent":"order",
                  "medicationCodeableConcept":{
                     "coding":[
                        {
                           "system":"http://www.nlm.nih.gov/research/umls/rxnorm",
                           "code":"617993",
                           "display":"Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
                        }
                     ],
                     "text":"Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
                  },
                  "subject":{
                     "reference":"Patient/1288992"
                  },
                  "dosageInstruction":[
                     {
                        "text":"5 mL bid x 10 days",
                        "timing":{
                           "repeat":{
                              "boundsPeriod":{
                                 "start":"2005-01-04"
                              },
                              "frequency":2,
                              "period":1,
                              "periodUnit":"d"
                           }
                        },
                        "doseQuantity":{
                           "value":5,
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
                        "value":10,
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
"context":{
  "userId":"Practitioner/123",
  "patientId":"1288992",
  "encounterId":"89284",
  "orders":{
    "resourceType":"Bundle",
    "entry":[
      {
        "resource":{
          "resourceType":"NutritionOrder",
          "id":"nest-patient-1-NUTR1",
          "patient":{
            "reference":"Patient/1288992"
          },
          "orderer":{
            "display":"Dr Adam Careful"
          },
          "identifier":[
            {
              "system":"http://goodhealthhospital.org/nutrition-orders",
              "value":"123"
            }
          ],
          "dateTime":"2014-09-17",
          "status":"draft",
          "oralDiet":{
            "type":[
              {
                "coding":[
                  {
                    "system":"http://snomed.info/sct",
                    "code":"435801000124108",
                    "display":"Texture modified diet"
                  },
                  {
                    "system":"http://goodhealthhospital.org/diet-type-codes",
                    "code":"1010",
                    "display":"Texture modified diet"
                  }
                ],
                "text":"Texture modified diet"
              }
            ],
            "schedule":[
              {
                "repeat":{
                  "boundsPeriod":{
                    "start":"2015-02-10"
                  },
                  "frequency":3,
                  "period":1,
                  "periodUnits":"d"
                }
              }
            ],
            "texture":[
              {
                "modifier":{
                  "coding":[
                    {
                      "system":"http://snomed.info/sct",
                      "code":"228049004",
                      "display":"Chopped food"
                    }
                  ],
                  "text":"Regular, Chopped Meat"
                },
                "foodType":{
                  "coding":[
                    {
                      "system":"http://snomed.info/sct",
                      "code":"22836000",
                      "display":"Vegetable"
                    }
                  ],
                  "text":"Regular, Chopped Meat"
                }
              }
            ]
          }
        }
      },
      {
        "resource":{
          "resourceType":"MedicationOrder",
          "id":"smart-MedicationOrder-103",
          "status":"draft",
          "patient":{
            "reference":"Patient/1288992"
          },
          "medicationCodeableConcept":{
            "coding":[
              {
                "system":"http://www.nlm.nih.gov/research/umls/rxnorm",
                "code":"617993",
                "display":"Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
              }
            ],
            "text":"Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
          },
          "dosageInstruction":[
            {
              "text":"5 mL bid x 10 days",
              "timing":{
                "repeat":{
                  "boundsPeriod":{
                    "start":"2005-01-04"
                  },
                  "frequency":2,
                  "period":1,
                  "periodUnits":"d"
                }
              },
              "doseQuantity":{
                "value":5,
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
              "value":10,
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
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
