# `order-review`

## Workflow description

The user is in the process of reviewing a set of orders to sign.

## Context

The set of orders being reviewed for signature on-screen. All FHIR resources in this _context_ MUST be based on the same FHIR version.

Field | Priority | Prefetch Token | Description
----- | -------- | ---- | ----
`patientId` | REQUIRED | Yes | *string*.  The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string*.  The FHIR `Encounter.id` of the current encounter in context
`orders` | REQUIRED | No | *object* DSTU2 - A FHIR Bundle of draft MedicationOrder, DiagnosticOrder, DeviceUseRequest, ReferralRequest, ProcedureRequest, NutritionOrder, VisionPrescription <br/> *object* STU3 - A FHIR Bundle of draft MedicationRequest, ReferralRequest, ProcedureRequest, NutritionOrder, VisionPrescription

### Example (DSTU2)

```json
"context": {
	"patientId": "1288992",
	"encounterId": "89284",
	"orders": {
		"resourceType": "Bundle",
		"entry": [{
			"resource": {
				"resourceType": "NutritionOrder",
				"id": "nest-patient-1-NUTR1",
				"patient": {
					"reference": "Patient/1288992",
					"display": "Tomy Francis"
				},
				"orderer": {
					"display": "Dr Adam Careful"
				},
				"identifier": [{
					"system": "http://goodhealthhospital.org/nutrition-orders",
					"value": "123"
				}],
				"dateTime": "2014-09-17",
				"status": "draft",
				"oralDiet": {
					"type": [{
						"coding": [{
							"system": "http://snomed.info/sct",
							"code": "435801000124108",
							"display": "Texture modified diet"
						},
						{
							"system": "http://goodhealthhospital.org/diet-type-codes",
							"code": "1010",
							"display": "Texture modified diet"
						}],
						"text": "Texture modified diet"
					}],
					"schedule": [{
						"repeat": {
							"boundsPeriod": {
								"start": "2015-02-10"
							},
							"frequency": 3,
							"period": 1,
							"periodUnits": "d"
						}
					}],
					"texture": [{
						"modifier": {
							"coding": [{
								"system": "http://snomed.info/sct",
								"code": "228049004",
								"display": "Chopped food"
							}],
							"text": "Regular, Chopped Meat"
						},
						"foodType": {
							"coding": [{
								"system": "http://snomed.info/sct",
								"code": "22836000",
								"display": "Vegetable"
							}],
							"text": "Regular, Chopped Meat"
						}
					}]
				}
			}
		},
		{
			"resource": {
				"resourceType": "MedicationOrder",
				"id": "smart-MedicationOrder-103",
				"status": "draft",
				"patient": {
					"reference": "Patient/1288992",
					"display": "Tomy Francis"
				},
				"medicationCodeableConcept": {
					"coding": [{
						"system": "http://www.nlm.nih.gov/research/umls/rxnorm",
						"code": "617993",
						"display": "Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
					}],
					"text": "Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
				},
				"dosageInstruction": [{
					"text": "5 mL bid x 10 days",
					"timing": {
						"repeat": {
							"boundsPeriod": {
								"start": "2005-01-04"
							},
							"frequency": 2,
							"period": 1,
							"periodUnits": "d"
						}
					},
					"doseQuantity": {
						"value": 5,
						"unit": "mL",
						"system": "http://unitsofmeasure.org",
						"code": "mL"
					}
				}],
				"dispenseRequest": {
					"numberOfRepeatsAllowed": 1,
					"quantity": {
						"value": 1,
						"unit": "mL",
						"system": "http://unitsofmeasure.org",
						"code": "mL"
					},
					"expectedSupplyDuration": {
						"value": 10,
						"unit": "days",
						"system": "http://unitsofmeasure.org",
						"code": "d"
					}
				}
			}
		}]
	}
}
```
