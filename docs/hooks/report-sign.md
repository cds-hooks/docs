# `report-sign`

| Metadata | Value
| ---- | ----
| specificationVersion | 2.0
| hookVersion | 0.1.0
| Hook maturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

The `report-sign` hook fires when a provider has finalized and signed a diagnostic report. This hook occurs right after the report has been promoted out of `preliminary` status and into `final` status. This hook will also occur right after the report has been promoted from `final` to `amended` status.

This proposal groups clinical workflows together for different departments until it is demonstrated that there are sufficiently different requirements to warrant splitting into separate hooks. For example, different departments include radiology, cardiology, laboratory, pathology, etc. However, this will require that additional parameters be defined in the prefetch of the CDS service.

The category code in the context data of this hook in [Context](#Context) identifies the department.

For example, in radiology, when a radiologist is confident that all of the findings in a study have been reported and all of the sections of a report are complete, they will sign the report so that it can be sent to the electronic health record (EHR). Alternatively, when a completed report needs to be amended, the radiologist will amend the report by submitting changes. The report status will then be changed to `amended` and re-sent to the EHR.

This hook shall not be used when a report is created or to call clinical decision support.
  
![Reporting Flow Diagram](../images/reportingflow.png)
<br>Figure 1: Proposed Reporting CDS Hooks Workflow. The above image shows the workflow order for when the reporting CDS Hooks would be triggered.

## Context

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The FHIR ID of the current user. <br>NOTE: For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html) or [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html). For example, Practitioner/123 or PractitionerRole/abc.
`patientId` | REQUIRED | Yes | *string* | The FHIR `Patient.id` of the current patient in context.
`encounterId` | OPTIONAL | Yes | *string* | The FHIR `Encounter.id` of the current encounter in context.
`reportId` | REQUIRED | Yes | *string* | The FHIR `DiagnosticReport.id` of the current report.
`category` | REQUIRED | No | *string* | The FHIR `DiagnosticReport.category` of the study. <br>NOTE: For example, radiology would have the category `RAD`, pathology `PAT`, and laboratory `LAB`.
`status` | REQUIRED | No | *string* | The FHIR `DiagnosticReport.status` of the report. <br>NOTE: For the category of radiology, the status codes `final` and `amended` are preferred.
`procedure` | OPTIONAL | No | *array* | The FHIR `DiagnosticReport.code` of this study, which refers to the procedure name.  <br>NOTE: For example, the procedure code, or set of procedure codes, that correspond to an imaging study are reported as LOINC codes.

## Examples
### Example (R4, R5, R6)

```json
"context": {
  "userId": "Practitioner/123",
  "patientId": "1288992",
  "encounterId": "89284",
  "reportId": "102",
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
  "status": "final",
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