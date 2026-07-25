# `report-assist`

| Metadata | Value
| ---- | ----
| specificationVersion | 2.0
| hookVersion | 0.1.0
| Hook maturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

The `report-assist` hook fires when a provider requests assistance from an external and interoperable CDS. This can happen anywhere in the reporting process: after `report-create` has been called and before `report-sign`.

This proposal groups clinical workflows together for different departments until it is demonstrated that there are sufficiently different requirements to warrant splitting into separate hooks. For example, different departments include radiology, cardiology, laboratory, pathology, etc. However, this will require that additional parameters be defined in the prefetch of the CDS service.

The category code in the context data of this hook in [Context](#Context) identifies the department.

For example, a radiologist is reviewing a CT of the chest and finds a lung nodule of concern. They need to calculate the American College of Radiology (ACR) Lung-RADS score to confirm if a biopsy should be recommended. The radiologist has all the required measurements, but doesn’t have the time to perform this calculation. This hook would trigger an external and interoperable application to calculate this score based on the measurements to determine risk of potential lung cancer. To the radiologist on the user interface of the reporting application, this may simply be a "calculate" button. Using the interoperable CDS will ensure that all of the data is available for submission to the ACR Lung Cancer Screening Registry.

This hook shall not be used to start or create a new report or to sign a report.

This hook is applicable for the status codes of `partial` and `preliminary`. It should be noted that new (additional) `resident-wetread` and `physician-wetread` (e.g., ED physician) status codes may be useful and applicable for this hook.
  
![Reporting Flow Diagram](../images/reportingflow.png)
<br>Figure 1: Proposed Reporting CDS Hooks Workflow. The above image shows the workflow order for when the reporting CDS Hooks would be triggered.

## Context

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The FHIR ID of the current user. <br>NOTE: For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html) or [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html). For example, Practitioner/123 or PractitionerRole/abc.
`patientId` | REQUIRED | Yes | *string* | The FHIR `Patient.id` of the current patient in context.
`encounterId` | OPTIONAL | Yes | *string* | The FHIR `Encounter.id` of the current encounter in context.
`reportId` | OPTIONAL | Yes | *string* | The FHIR `DiagnosticReport.id` of the current report.
`category` | REQUIRED | No | *string* | The FHIR `DiagnosticReport.category` of the study. <br>NOTE: For example, radiology would have the category `RAD`, pathology `PAT`, and laboratory `LAB`.
`status` | OPTIONAL | No | *string* | The FHIR `DiagnosticReport.status` of the report. <br>NOTE: For the category of radiology, the status codes `preliminary` and `partial` are preferred. <br><br>It should be noted that new (additional) status codes of `resident-wetread` and `physician-wetread` (e.g. ED physician) may be useful.
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
