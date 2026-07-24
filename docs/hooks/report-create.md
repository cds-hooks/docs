# `report-create`

| Metadata | Value
| ---- | ----
| specificationVersion | 2.0
| hookVersion | 0.1.0
| Hook maturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

The `report-create` hook fires when a provider creates a new diagnostic report.

This proposal groups clinical workflows together for different departments until it is demonstrated that there are sufficiently different requirements to warrant splitting into separate hooks. For example, different departments include radiology, cardiology, laboratory, pathology, etc. However, this will require that additional parameters be defined in the prefetch of the CDS service.

The category code in the context data of this hook in [Context](#Context) identifies the department.

An example workflow for radiology is that this hook would be triggered when the radiologist selects an item for reporting from the reading worklist on the Picture Archive and Computing System (PACS). In this example, this trigger could be used to select the correct report template or to retrieve additional information from the EHR.

This hook shall not be used when a report is being amended or to call clinical decision support.

This hook shall only be used for the status codes of `partial` and `preliminary`.
  
![Reporting Flow Diagram](../images/reportingflow.png)
Figure 1: Proposed CDS Hooks Workflow. The above image shows the workflow order for when these CDS Hooks would be triggered.

## Context

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The FHIR ID of the current user. <br>NOTE: For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html) or [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html). For example, Practitioner/123 or PractitionerRole/abc.
`patientId` | REQUIRED | Yes | *string* | The FHIR `Patient.id` of the current patient in context.
`encounterId` | OPTIONAL | Yes | *string* | The FHIR `Encounter.id` of the current encounter in context.
`category` | REQUIRED | No | *string* | The FHIR `DiagnosticReport.category` of the study. <br>NOTE: For example, radiology would have the category `RAD`, pathology `PAT`, and laboratory `LAB`.
`status` | REQUIRED | No | *string* | The FHIR `DiagnosticReport.status` of the new report or report template. <br>NOTE: For the category of radiology, the status codes `preliminary` and `partial` are preferred. <br><br>It should be noted that new (additional) status codes of `resident-wetread` and `physician-wetread` (e.g. ED physician) may be useful.
`procedure` | OPTIONAL | No | *array* | The FHIR `DiagnosticReport.code` of this study, which refers to the procedure name.  <br>NOTE: For example, the procedure code, or set of procedure codes, that correspond to an imaging study are reported as LOINC codes.

## Examples
### Example (R4, R5, R6)

```json
"context": {
  "userId": "Practitioner/123",
  "patientId": "1288992",
  "encounterId": "89284",
  "category": [
    {
      "coding": [
        {
           "system": "http://terminology.hl7.org/CodeSystem/v2-0074",
           "code": "RAD"
        }
      ]
    }
  ],
  "status": "preliminary",
  "procedure": {
      "coding": [
        {
           "system": "https://loinc.org",
           "code": "24627-2",
        }
      ],
   "text": "CT Chest"
  }
}
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
