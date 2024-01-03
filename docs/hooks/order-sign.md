# `order-sign`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0
| Hook maturity | [5 - Mature](../../specification/current/#hook-maturity-model)

## Workflow

The `order-sign` hook fires when a clinician is ready to sign one or more orders for a patient, (including orders for medications, procedures, labs and other orders).
This hook is among the last workflow events before an order is promoted out of a draft status. 
The context contains all order details, such as dose, quantity, route, etc, 
although the order has not yet been signed and therefore still exists in a draft status. 
Use this hook when your service requires all order details, and the clinician will accept recommended changes.

This hook can also be used when an order or set of orders is being 're-signed' after revision (e.g. change
to status, extending dates, or other changes allowed to signed orders within the system's workflow).  In this
case, the orders would typically have a status other than 'draft'.  In some cases, the hook might fire with a
mixture of new and revised orders.

This hook is intended to replace (deprecate) the `medication-prescribe` and `order-review` hooks. 

## Context

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html) or [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html).<br />For example, `PractitionerRole/123` or `Practitioner/abc`.
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* |  The FHIR `Encounter.id` of the current encounter in context
`draftOrders` | REQUIRED | No | *object* | A Bundle of FHIR request resources with a draft status, representing orders that aren't yet signed from the current ordering session. 

### A Note Concerning FHIR Versions

CDS Hooks is designed to be agnostic of FHIR version. For example, all versions of FHIR can represent in-progress orders but over time, the specific resource name and some of the important elements have changed.  Below are some of the mosty commonly used FHIR resources for representing an order in CDS Hooks. This list is intentionally not comprehensive. 
* DSTU2 - FHIR Bundle of MedicationOrder, ProcedureRequest
* STU3 - FHIR Bundle of MedicationRequest, ProcedureRequest
* R4 - FHIR Bundle of MedicationRequest, ServiceRequest

## Examples

### Example (R4)

```json
{
   "context":{
      "userId":"PractitionerRole/123",
      "patientId":"1288992",
      "encounterId":"89284",
      "draftOrders":{
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

### Example (STU3)

```json
{
   "context":{
      "userId":"Practitioner/example",
      "patientId":"1288992",
      "encounterId":"89284",
      "draftOrders":{
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
                        "doseAndRate":{
                           "doseQuantity":{
                              "value":5,
                              "unit":"mL",
                              "system":"http://unitsofmeasure.org",
                              "code":"mL"
                           }
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
  "userId":"Practitioner/abc",
  "patientId":"1288992",
  "encounterId":"89284",
  "draftOrders":{
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
1.0.1 | Add DeviceRequest to list of order resources for R4.
1.1.0 | Updated hook to all for use in order-revision situations
