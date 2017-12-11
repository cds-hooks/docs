# `patient-view`

## Workflow description
The user has just opened a patient's record.

## Contextual data
The patient whose record is currently open. 

|key|data|required?|
|---|---|---|
|patient|Patient FHIR id|Yes|
|encounter|Encounter FHIR id|No|


```json
{
	"context": {
		"patient": "1b102e3f-dbd4-4b53-a7bf-a3bd80afd93a",
	}
}
```