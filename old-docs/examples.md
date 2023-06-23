# Examples

## CDC Guideline for Prescribing Opioids for Chronic Pain

> CDS Service Request

> The example illustrates a prescription for Acetaminophen/Hydrocodone Bitartrate for a patient that already has a prescription for Oxycodone Hydrochloride:

```json
{
  "hookInstance": "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
  "fhirServer": "http://fhir.example.com",
  "hook": "order-sign",
  "context": {
    "userId": "Practitioner/example",
    "medications": [
      {
        "resourceType": "MedicationOrder",
        "id": "medrx001",
        "dateWritten": "2017-05-05",
        "status": "draft",
        "patient": {
          "reference": "Patient/example"
        },
        "medicationCodeableConcept": {
          "coding": [
            {
              "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
              "code": "857001",
              "display": "Acetaminophen 325 MG / Hydrocodone Bitartrate 10 MG Oral Tablet"
            }
          ]
        },
        "dosageInstruction": [
          {
            "text": "Take 1 tablet Oral every 4 hours as needed",
            "timing": {
              "repeat": {
                "frequency": 6,
                "frequencyMax": 6,
                "period": 1,
                "unit": "d"
              }
            },
            "asNeededBoolean": true,
            "doseQuantity": {
              "value": 10,
              "unit": "mg",
              "system": "http://unitsofmeasure.org",
              "code": "mg"
            }
          }
        ]
      }
    ],
    "patientId": "1288992"
  },
  "prefetch": {
    "medication": {
      "response": {
        "status": "200 OK"
      },
      "resource": {
        "resourceType": "MedicationOrder",
        "id": "medrx002",
        "dateWritten": "2017-04-25",
        "status": "active",
        "patient": {
          "reference": "Patient/example"
        },
        "medicationCodeableConcept": {
          "coding": [
            {
              "system": "http://www.nlm.nih.gov/research/umls/rxnorm",
              "code": "1049621",
              "display": "Oxycodone Hydrochloride 5 MG Oral Tablet"
            }
          ]
        },
        "dosageInstruction": [
          {
            "text": "Take 1 tablet by mouth every 4 hours as needed for pain.",
            "timing": {
              "repeat": {
                "frequency": 6,
                "period": 1,
                "periodUnits": "d"
              }
            },
            "asNeededBoolean": true,
            "doseQuantity": {
              "value": 5,
              "unit": "mg",
              "system": "http://unitsofmeasure.org",
              "code": "mg"
            }
          }
        ]
      }
    }
  }
}
```

This example illustrates the use of the CDS Hooks `medication-prescribe` hook to implement Recommendation #5 from the [CDC guideline for prescribing opioids for chronic pain](https://guidelines.gov/summaries/summary/50153/cdc-guideline-for-prescribing-opioids-for-chronic-pain---united-states-2016#420).

This example is taken from the [Opioid Prescribing Support Implementation Guide](http://build.fhir.org/ig/cqframework/opioid-cds/), developed in partnership with the Centers for Disease Control and Prevention [(CDC)](https://www.cdc.gov/).

> CDS Service Response

> The opioid guideline request results in the following response that indicates the patient is at high risk for opioid overdose according to the CDC guidelines, and the dosage should be tapered to less than 50 MME. Links are provided to the guideline, as well as to the MME conversion tables provided by CDC.

```json
{
  "summary": "High risk for opioid overdose - taper now",
  "indicator": "warning",
  "links": [
    {
      "label": "CDC guideline for prescribing opioids for chronic pain",
      "type": "absolute",
      "url": "https://guidelines.gov/summaries/summary/50153/cdc-guideline-for-prescribing-opioids-for-chronic-pain---united-states-2016#420"
    },
    {
      "label": "MME Conversion Tables",
      "type": "absolute",
      "url": "https://www.cdc.gov/drugoverdose/pdf/calculating_total_daily_dose-a.pdf"
    }
  ],
  "detail": "Total morphine milligram equivalent (MME) is 125mg. Taper to less than 50."
}
```

## Radiology Appropriateness

> CDS Service Request

> This example illustrates the use of the CDS Hooks `order-select` hook to implement Radiology Appropriateness scoring.

```json
{
  "hook": "order-select",
  "hookInstance": "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
  "fhirServer": "http://hooks.smarthealthit.org:9080",
  "context": {
    "userId": "Practitioner/123",
    "patientId": "MRI-59879846",
    "encounterId": "89284",
    "selections": [
      "ServiceRequest/example-MRI-59879846"
    ],
    "draftOrders": {
      "resourceType": "Bundle",
      "entry": [
        {
          "resource": {
            "resourceType": "ServiceRequest",
            "id": "example-MRI-59879846",
            "status": "draft",
            "intent": "plan",
            "code": {
              "coding": [
                {
                  "system": "http://loinc.org",
                  "code": "36801-9"
                }
              ],
              "text": "MRA Knee Vessels Right"
            },
            "subject": {
              "reference": "Patient/MRI-59879846"
            },
            "reasonCode": [
              {
                "coding": [
                  {
                    "system": "http://hl7.org/fhir/sid/icd-10",
                    "code": "S83.511",
                    "display": "Sprain of anterior cruciate ligament of right knee"
                  }
                ]
              }
            ]
          }
        }
      ]
    }
  }
}
```

> CDS Service Response

> The appropriateness score is communicated via a `systemAction` of the ServiceRequest that adds an extension element to indicate the appropriateness rating. See the [CDS Hooks for PAMA Argonaut specification](https://github.com/argonautproject/cds-hooks-for-pama/blob/master/docs/index.md) for more.

```json
{
   "cards":[
      
   ],
   "systemActions":[
      {
         "type":"update",
         "resource":{
            "resourceType":"ServiceRequest",
            "id":"example-MRI-59879846",
            "extension":[
               {
                  "url":"http://fhir.org/argonaut/Extension/pama-rating",
                  "valueCodeableConcept":{
                     "coding":[
                        {
                           "system":"http://fhir.org/argonaut/CodeSystem/pama-rating",
                           "code":"appropriate"
                        }
                     ]
                  }
               },
               {
                  "url":"http://fhir.org/argonaut/Extension/pama-rating-consult-id",
                  "valueUri":"urn:uuid:55f3b7fc-9955-420e-a460-ff284b2956e6"
               }
            ],
            "status":"draft",
            "intent":"plan",
            "code":{
               "coding":[
                  {
                     "system":"http://loinc.org",
                     "code":"36801-9"
                  }
               ],
               "text":"MRA Knee Vessels Right"
            },
            "subject":{
               "reference":"Patient/MRI-59879846"
            },
            "reasonCode":[
               {
                  "coding":[
                     {
                        "system":"http://hl7.org/fhir/sid/icd-10",
                        "code":"S83.511",
                        "display":"Sprain of anterior cruciate ligament of right knee"
                     }
                  ]
               }
            ]
         }
      }
   ]
}
```
