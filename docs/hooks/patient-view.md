# `patient-view`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0

## Workflow

The user has just opened a patient's record.

## Context

The patient whose record was opened, including their encounter, if applicable.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The FHIR resource type + id representing the current user.<br />The type is one of: [Practitioner](https://www.hl7.org/fhir/practitioner.html), [Patient](https://www.hl7.org/fhir/patient.html), or [RelatedPerson](https://www.hl7.org/fhir/relatedperson.html).<br />For example, `Practitioner/123`
`patientId` | REQUIRED | Yes | *string* | The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* | The FHIR `Encounter.id` of the current encounter in context

### Examples

```json
"context":{
  "userId" : "Practitioner/123",
  "patientId" : "1288992"
}
```

```json
"context":{
  "userId" : "Practitioner/123",
  "patientId" : "1288992",
  "encounterId" : "456"
}
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release

