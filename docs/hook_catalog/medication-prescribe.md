## `medication-prescribe`

**Workflow description**: The user is in the process of prescribing a new medication, and solicit feedback about the prescription-in-progress.

**Contextual data**: The set of medication proposed or in progress of being prescribed.

|key|data|FHIR resource version|
|---|---|---|
|patient|Patient FHIR id|n/a|
|encounter|Encounter FHIR id|n/a|
|medications|MedicationOrder resource or MedicationRequest resource|DSTU2 or STU3|

```json
{
  "context": {
	"patient": "smart-1081332",
	"medications-in-progress:" [
		{
		  "resourceType": "MedicationOrder",
		  "id": "smart-MedicationOrder-103",
		  "status": "draft",
		  "patient": {
			"reference": "Patient/smart-1081332"
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
		{
		  "resourceType": "MedicationOrder",
		  "id": "smart-MedicationOrder-104",
		  "status": "draft",
		  "patient": {
			"reference": "Patient/smart-1081332"
		  },
		  "medicationCodeableConcept": {
			"coding": [
			  {
				"system": "http://www.nlm.nih.gov/research/umls/rxnorm",
				"code": "211307",
				"display": "Azithromycin 20 MG/ML Oral Suspension [Zithromax]"
			  }
			],
			"text": "Azithromycin 20 MG/ML Oral Suspension [Zithromax]"
		  },
		  "dosageInstruction": [
			{
			  "text": "15 mL daily x 3 days",
			  "timing": {
				"repeat": {
				  "boundsPeriod": {
					"start": "2005-01-18"
				  },
				  "frequency": 1,
				  "period": 1,
				  "periodUnits": "d"
				}
			  },
			  "doseQuantity": {
				"value": 15,
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
			  "value": 3,
			  "unit": "days",
			  "system": "http://unitsofmeasure.org",
			  "code": "d"
			}
		  }
		}
	]
    }
  }
}
```





