# `order-review`

## Workflow description
Inform an external CDS service that the user is in the process of reviewing a set of orders.

## Contextual data
The set of orders being reviewed on-screen, represented at least one of MedicationOrder, DiagnosticOrder, DeviceUseRequest, ReferralRequest, ProcedureRequest, NutritionOrder, and VisionPrescription. Note that all FHIR resources in a single CDS request should be the same version of FHIR. 

|key|data|required?|
|---|---|---|
|patient|Patient FHIR id|Yes|
|encounter|Encounter FHIR id|No|
|orders-in-progress|DSTU2 - Array of MedicationOrder, DiagnosticOrder,DeviceUseRequest, ReferralRequest, ProcedureRequest, NutritionOrder, VisionPrescription <br/> STU3 - Array of MedicationRequest, ReferralRequest, ProcedureRequest, NutritionOrder, VisionPrescriptionVisionPrescription|Yes|

```json
{
  "context": {
  	"patient": "nest-patient-1-NUTR1",
	"orders-in-progress:" [
		{
		  "resourceType": "NutritionOrder",
		  "id": "nest-patient-1-NUTR1",
		  "patient": {
			"reference": "Patient/nest-patient-1",
			"display": "Tomy Francis"
		  },
		  "orderer": {
			"display": "Dr Adam Careful"
		  },
		  "identifier": [
			{
			  "system": "http://goodhealthhospital.org/nutrition-orders",
			  "value": "123"
			}
		  ],
		  "dateTime": "2014-09-17",
		  "status": "proposed",
		  "oralDiet": {
			"type": [
			  {
				"coding": [
				  {
					"system": "http://snomed.info/sct",
					"code": "435801000124108",
					"display": "Texture modified diet"
				  },
				  {
					"system": "http://goodhealthhospital.org/diet-type-codes",
					"code": "1010",
					"display": "Texture modified diet"
				  }
				],
				"text": "Texture modified diet"
			  }
			],
			"schedule": [
			  {
				"repeat": {
				  "boundsPeriod": {
					"start": "2015-02-10"
				  },
				  "frequency": 3,
				  "period": 1,
				  "periodUnits": "d"
				}
			  }
			],
			"texture": [
			  {
				"modifier": {
				  "coding": [
					{
					  "system": "http://snomed.info/sct",
					  "code": "228049004",
					  "display": "Chopped food"
					}
				  ],
				  "text": "Regular, Chopped Meat"
				},
				"foodType": {
				  "coding": [
					{
					  "system": "http://snomed.info/sct",
					  "code": "22836000",
					  "display": "Vegetable"
					}
				  ],
				  "text": "Regular, Chopped Meat"
				}
			  }
			]
		  }
		},
		{
		  "resourceType": "MedicationOrder",
		  "id": "smart-MedicationOrder-103",
		  "status": "draft",
		  "patient": {
			"reference": "Patient/nest-patient-1",
			"display": "Tomy Francis"
		  },
		  "medicationCodeableConcept": {
			"coding": [
			  {
				"system": "http://www.nlm.nih.gov/research/umls/rxnorm",
				"code": "617993",
				"display": "Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
			  }
			],
			"text": "Amoxicillin 120 MG/ML / clavulanate potassium 8.58 MG/ML Oral Suspension"
		  },
		  "dosageInstruction": [
			{
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
			}
		  ],
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
		},
	]
  }
}
```