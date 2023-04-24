# `questionnaire-inprogress`

!!! info
    This page defines a workflow [hook](../../specification/current/#hooks) for the purpose of providing clinical decision support using CDS Hooks. This is a **build** at the level of **[Draft](http://hl7.org/fhir/versions.html#std-processs)**

| Metadata | Value |
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0
| hookMaturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

This hook is invoked whenever a user is in the progress of answering a questionnaire.
It may be invoked continuously during answering a questionnaire, at the start, or after finishing it.
The hook provides feedback on the content of the filled questionnaire, represented as a 
`QuestionnaireResponse`. The `QuestionnaireResponse` within the `context.questionnaireReponse` MUST be a valid 
FHIR Resource, but can be regarded as transient data and only MAY be stored in a FHIR server already.
Given the high number and variability of Questionnaires, the hook is defined sparsely to offer implementers freedom for
their respective use-case. A loose collection of possible workflows are:
- Interactive information for helping in filling out / completing the form
- Offering potential caretakers, including appointments, in the area of a patient for provided symptoms
- Showing medical personnel relevant differential diagnoses given a set of answers
- Offering order sets when finishing an admission form
- Offering adding entered information as structured Observations to a patients EHR

## Context

The current response data of the questionnaire in progress, as well as the identifiers for the current encounter if fitting.

Field | Optionality | Prefetch Token | Type     | Description
----- | -------- | ---- |----------| ----
`questionnaireResponse` | REQUIRED | Yes | *object* | A single [QuestionnaireResponse](https://www.hl7.org/fhir/questionnaireresponse.html) resource
`userId` | OPTIONAL | Yes | *string* | The id of the current user.<br />For this hook, the user could be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html), [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html), [Patient](https://www.hl7.org/fhir/patient.html), or [RelatedPerson](https://www.hl7.org/fhir/relatedperson.html).<br />For example, `Practitioner/123`
`patientId` | OPTIONAL | Yes | *string* | The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* | The FHIR `Encounter.id` of the current encounter in context


### Examples


```json
"context": {
  "questionnaireResponse" :
    {
    "resourceType": "QuestionnaireResponse",
    "id": "gcs",
    "questionnaire": "http://hl7.org/fhir/Questionnaire/gcs",
    "status": "completed",
    "subject": {
        "reference": "Patient/example",
        "display": "Peter James Chalmers"
    },
    "authored": "2014-12-11T04:44:16Z",
    "source": {
      "reference": "Practitioner/f007"
    },
    "item": [
        {
            "linkId": "1.1",
            "answer": [
                {
                "valueCoding": {
                    "extension": [
                        {
                            "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                            "valueDecimal": 4
                        }
                    ],
                    "system": "http://loinc.org",
                    "code": "LA6560-2",
                    "display": "Confused"
                    }
                }
            ]
        },
        {
            "linkId": "1.2",
            "answer": [
                {
                "valueCoding": {
                    "extension": [
                        {
                            "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                            "valueDecimal": 5
                        }
                    ],
                    "system": "http://loinc.org",
                    "code": "LA6566-9",
                    "display": "Localizing pain"
                    }
                }
            ]
        },
        {
            "linkId": "1.3",
            "answer": [
                {
                "valueCoding": {
                    "extension": [
                        {
                            "url": "http://hl7.org/fhir/StructureDefinition/ordinalValue",
                            "valueDecimal": 4
                        }
                    ],
                    "system": "http://loinc.org",
                    "code": "LA6556-0",
                    "display": "Eyes open spontaneously"
                    }
                }
            ]
        }
    ]
  }
}
```


## Change Log

Version | Description
---- | ----
1.0 | Initial Release
