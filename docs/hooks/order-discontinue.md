`order-discontinue`

!!! info
    This page defines a workflow [hook](../../specification/current/#hooks) for the purpose of providing clinical decision support using CDS Hooks. This is a build at the level of [Draft](http://hl7.org/fhir/versions.html#std-processs).

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 0.1.0
| hookMaturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

The `order-discontinue` fires when a signed order is manually discontinued by a clinician (including orders for medications, procedures, labs and other orders). Note that this hook does not fire when an order expires "naturally", for example at a predictable time, such as a a medication prescription's refills completing.

## Context
CDS Services should consider retreiving or prefetch'ing the `toBeDiscontinued` order, and should focus decisions support on the discontinuation of this order.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html) or [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html).<br />For example, `PractitionerRole/123` or `Practitioner/abc`.
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* |  The FHIR `Encounter.id` of the current encounter in context
`toBeDiscontinued` | REQUIRED | No| *object* | FHIR Bundle with the orders resources bring discontinued.  <br/ > DSTU2 - FHIR Bundle of MedicationOrder, DiagnosticOrder, DeviceUseRequest, ReferralRequest, ProcedureRequest, NutritionOrder, VisionPrescription. <br/ > STU3 - FHIR Bundle of MedicationRequest, ReferralRequest, ProcedureRequest, NutritionOrder, VisionPrescription. <br/ > R4 - FHIR Bundle of DeviceRequest, MedicationRequest, NutritionOrder, ServiceRequest, VisionPrescription.  

## Examples

### Example (R4)

```json
{
   "context":{
      "userId":"PractitionerRole/123",
      "patientId":"1288992",
      "encounterId":"89284",
      "toBeDiscontinued": 
      {
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
            }
        }
   }
}
```


## Change Log

Version | Description
---- | ----
0.1.0 | Proposed
