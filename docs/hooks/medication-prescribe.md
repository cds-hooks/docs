# `medication-prescribe`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0
| Hook maturity | [2 - Tested](../../specification/1.0/#hook-maturity-model)


## Deprecation Notice

This hook is deprecated in favor of the `order-select` and `order-sign` hooks, with the goal of  clarifying workflow trigger points and supporting orders beyond medications. In this refactoring, `medication-prescribe` and `order-review` hooks are being deprecated in favor of newly created [`order-select`](../order-select) and [`order-sign`](../order-sign) hooks. This notice is a placeholder to this effect while CDS Hooks determines the [appropriate process for deprecating hooks](https://github.com/cds-hooks/docs/issues/433).

## Workflow

The user is in the process of prescribing one or more new medications.

## Context

The set of medications proposed or in progress of being prescribed. All FHIR resources in this context MUST be based on the same FHIR version. All FHIR resources in the medications object MUST have a status of _draft_.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html).<br />For example, `Practitioner/123`
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
        },
        {
          "resource":{
            "resourceType":"MedicationRequest",
            "id":"smart-MedicationRequest-104",
            "meta":{
              "lastUpdated":"2018-04-30T13:26:48.124-04:00"
            },
            "text":{
              "status":"generated",
              "div":"<div xmlns=\"http://www.w3.org/1999/xhtml\">Azithromycin 20 MG/ML Oral Suspension [Zithromax] (rxnorm: 211307)</div>"
            },
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
        },
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
1.0 | Initial Release
