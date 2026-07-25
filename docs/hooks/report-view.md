# `report-view`

| Metadata | Value
| ---- | ----
| specificationVersion | 2.0
| hookVersion | 0.1.0
| Hook maturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

The `report-view` hook fires when a provider opens up to view a diagnostic report after it has been created. This hook shall occur for any report status: `partial`, `preliminary`, `final`, and `amended`. It should be noted that new (additional) `resident-wetread` and `physician-wetread` (e.g., ED physician) status codes may be useful and applicable for this hook.

This proposal groups clinical workflows together for different departments until it is demonstrated that there are sufficiently different requirements to warrant splitting into separate hooks. For example, different departments include radiology, cardiology, laboratory, pathology, etc. However, this will require that additional parameters be defined in the prefetch of the CDS service.

The category code in the context data of this hook in [Context](#Context) identifies the department.

For example, in radiology, if a radiologist has completed a study and signed the report, yet the next day new pathology results are available, the radiologist may want to reopen the report to view it with the new context. When the report is reopened, this hook would be triggered. Additionally, before a radiology report has been signed, it needs to be reviewed by a resident and a second physician. Adding both of the previously mentioned statuses, `physcian-wetread` and `resident-wetread`, could be useful here. This would move the report from the `resident-wetread` to `physician-wetread` status before moving to `final` status, rather than simply keeping it in `preliminary` status. Every time a new physician opens up the report to review it before the status changes, the hook would be triggered.

This hook shall not be used when a report is created, to call clinical decision support, or to sign a report.
  
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
`status` | REQUIRED | No | *string* | The FHIR `DiagnosticReport.status` of the report. <br>NOTE: For the category of radiology, the status codes `partial`, `preliminary`, `final`, and `amended` are preferred. <br><br>It should be noted that new (additional) status codes of `resident-wetread` and `physician-wetread` (e.g. ED physician) may be useful.
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