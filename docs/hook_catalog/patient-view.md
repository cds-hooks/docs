# `patient-view`

## Workflow description
The user has just opened a patient's record.

## Contextual data
The patient whose record is currently open. 

|key|data|cardinality|
|---|---|---|
|patient|DSTU2 - Patient <br/>STU3 - Patient |1..1|


```json
{
	"context": {
		"patient": {
		  "resourceType": "Patient",
		  "id": "1b102e3f-dbd4-4b53-a7bf-a3bd80afd93a",
		  "extension": [
			{
			  "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-race",
			  "valueCodeableConcept": {
				"coding": [
				  {
					"system": "http://hl7.org/fhir/v3/Race",
					"code": "2106-3",
					"display": "White"
				  }
				],
				"text": "race"
			  }
			},
			{
			  "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-ethnicity",
			  "valueCodeableConcept": {
				"coding": [
				  {
					"system": "http://hl7.org/fhir/v3/Ethnicity",
					"code": "2186-5",
					"display": "Nonhispanic"
				  }
				],
				"text": "ethnicity"
			  }
			},
			{
			  "url": "http://hl7.org/fhir/StructureDefinition/birthPlace",
			  "valueAddress": {
				"city": "Brookline",
				"state": "MA",
				"country": "US"
			  }
			},
			{
			  "url": "http://hl7.org/fhir/StructureDefinition/patient-mothersMaidenName",
			  "valueString": "Gayla Keebler"
			},
			{
			  "url": "http://hl7.org/fhir/us/core/StructureDefinition/us-core-birthsex",
			  "valueCode": "F"
			},
			{
			  "url": "http://hl7.org/fhir/StructureDefinition/patient-interpreterRequired",
			  "valueBoolean": false
			}
		  ],
		  "identifier": [
			{
			  "system": "https://github.com/synthetichealth/synthea",
			  "value": "42782785-fbc7-489f-9c01-e5bca83460c5"
			},
			{
			  "type": {
				"coding": [
				  {
					"system": "http://hl7.org/fhir/identifier-type",
					"code": "SB"
				  }
				]
			  },
			  "system": "http://hl7.org/fhir/sid/us-ssn",
			  "value": "999682598"
			},
			{
			  "type": {
				"coding": [
				  {
					"system": "http://hl7.org/fhir/v2/0203",
					"code": "DL"
				  }
				]
			  },
			  "system": "urn:oid:2.16.840.1.113883.4.3.25",
			  "value": "S99927840"
			},
			{
			  "type": {
				"coding": [
				  {
					"system": "http://hl7.org/fhir/v2/0203",
					"code": "MR"
				  }
				]
			  },
			  "system": "http://hospital.smarthealthit.org",
			  "value": "42782785-fbc7-489f-9c01-e5bca83460c5"
			}
		  ],
		  "name": [
			{
			  "use": "official",
			  "family": [
				"Collins"
			  ],
			  "given": [
				"Genevive"
			  ],
			  "prefix": [
				"Mrs."
			  ]
			},
			{
			  "use": "maiden",
			  "family": [
				"Mueller"
			  ],
			  "given": [
				"Genevive"
			  ]
			}
		  ],
		  "telecom": [
			{
			  "system": "phone",
			  "value": "1-544-556-5661 x30508",
			  "use": "home"
			}
		  ],
		  "gender": "female",
		  "birthDate": "1961-02-28",
		  "address": [
			{
			  "extension": [
				{
				  "url": "http://hl7.org/fhir/StructureDefinition/geolocation",
				  "extension": [
					{
					  "url": "latitude",
					  "valueDecimal": 42.10861898219526
					},
					{
					  "url": "longitude",
					  "valueDecimal": -71.97379522335262
					}
				  ]
				}
			  ],
			  "line": [
				"918 Wisozk Fields"
			  ],
			  "city": "Charlton",
			  "state": "MA",
			  "postalCode": "01507",
			  "country": "US"
			}
		  ],
		  "maritalStatus": {
			"coding": [
			  {
				"system": "http://hl7.org/fhir/v3/MaritalStatus",
				"code": "M"
			  }
			],
			"text": "M"
		  },
		  "multipleBirthBoolean": false,
		  "communication": [
			{
			  "language": {
				"coding": [
				  {
					"system": "http://hl7.org/fhir/ValueSet/languages",
					"code": "en-US",
					"display": "English (United States)"
				  }
				]
			  }
			}
		  ]
		}
	}
}
```