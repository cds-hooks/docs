# Hook Catalog

## Pre-defined CDS hooks

We describe a set of hooks to support common use cases out of the box.
But **this is not a closed set**; anyone can define new hooks to address new use
cases. To propose a new hooks please add it to the [proposed hooks](https://github.com/cds-hooks/docs/wiki/Proposed-Hooks) page of our wiki.

Note that each hook (e.g. `medication-prescribe`) represents something the user is doing in the EHR; various hooks might respond to the same hook (e.g. a "price check" service and a "prior authorization" service might both respond to `medication-prescribe`).

Note also that each hook name in our official catalog is a simple string. If
you want to define custom hooks without submitting them to the catalog, then
you should use a URI (e.g.
`http://my-organization/custom-hooks/patient-transmogrify`).


## `medication-prescribe`


```json
{
  "context": {
    "resourceType": "MedicationOrder",
    "medicationCodeableConcept": {
      "...": "<snipped for brevity>"
    }
  }
}
```

**Purpose**: Inform an external CDS service that the user is in the process of
prescribing a new medication, and solicit feedback about the
prescription-in-progress.

**Contextual data**: The set of proposed medication prescriptions. using the
FHIR `MedicationOrder` resource. See example in the sidebar.

## `order-review`

```json
{
  "context": {
    "resourceType": "DiagnosticOrder",
    "...": "<snipped for brevity>"
  }
}
```

**Purpose**: Inform an external CDS service that the user is in the process of
reviewing a set of orders (sometimes known as a "shopping cart"), and solicit
feedback about the orders being reviewed.




**Contextual data**: The set of orders being reviewed on-screen, represented
using a combination of MedicationOrder, DiagnosticOrder, DeviceUseRequest,
ReferralRequest, and ProcedureRequest. See example in the sidebar.

## `patient-view`

**Purpose**: Inform an external CDS service that the user has just opened a new
patient record and is viewing a summary screen or "face sheet", and solicit
feedback about this patient.

**Contextual data**: None required beyond default context.
# Examples

## CDC Guideline for Prescribing Opioids for Chronic Pain

> CDS Service Request

> The example illustrates a prescription for Acetaminophen/Hydrocodone Bitartrate for a patient that already has a prescription for Oxycodone Hydrochloride:

```json
{
  "hookInstance": "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
  "fhirServer": "http://fhir.example.com",
  "hook": "medication-prescribe",
  "user": "Practitioner/example",
  "context": [
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
  "patient": "Patient/example",
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

> This example illustrates the use of the CDS Hooks `order-review` hook to implement Radiology Appropriateness scoring.

```json
{
  "hookInstance": "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
  "fhirServer": "http://fhir.example.com",
  "hook": "order-review",
  "user": "Practitioner/example",
  "context": [
    {
      "resourceType": "ProcedureRequest",
      "id": "procedure-request-1",
      "status": "draft",
      "intent": "proposal",
      "priority": "routine",
      "code": {
        "coding": [{
          "system": "http://www.ama-assn.org/go/cpt",
          "code": "70450",
          "display": "CT, head, wo iv contrast"
        }]
      },
      "subject": {
        "reference": "Patient/example"
      },
      "requester": {
        "agent": {
          "reference": "Practitioner/exampmle"
        }
      }
    }
  ],
  "patient": "Patient/example"
}
```

> CDS Service Response

> The appropriateness score is communicated via an update of the procedure request that adds an extension element to indicate the appropriateness rating.

```json
{
  "cards": [
    {
      "summary": "Usually appropriate",
      "indicator": "info",
      "detail": "The requested procedure is usually appropriate for the given indications.",
      "suggestions": [
        {
          "label": "The appropriateness score for this procedure given these indications is 9, usually appropriate.",
          "actions": [{
            "type": "update",
            "description": "Update the order to record the appropriateness score.",
            "resource": {
              "resourceType": "ProcedureRequest",
              "id": "procedure-request-1",
              "extension": [
                {
                  "url": "http://hl7.org/fhir/us/qicore/StructureDefinition/procedurerequest-appropriatenessScore",
                  "valueDecimal": "9"
                }
              ],
              "status": "draft",
              "intent": "proposal",
              "priority": "routine",
              "code": {
                "coding": [{
                  "system": "http://www.ama-assn.org/go/cpt",
                  "code": "70450",
                  "display": "CT, head, wo iv contrast"
                }]
              },
              "subject": {
                "reference": "Patient/example"
              },
              "requester": {
                "agent": {
                  "reference": "Practitioner/exampmle"
                }
              }
            }
          }]
        }
      ]
    }
  ]
}
```
