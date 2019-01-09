# `patient-view`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0
| Hook maturity | [4 - Documented](../../specification/1.0/#hook-maturity-model)

## Workflow

The user has just opened a patient's record.

## Context

The patient whose record was opened, including their encounter, if applicable.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For example, if the user represents a FHIR resource on the given FHIR server, the resource type would be one of [Practitioner](https://www.hl7.org/fhir/practitioner.html), [Patient](https://www.hl7.org/fhir/patient.html), or [RelatedPerson](https://www.hl7.org/fhir/relatedperson.html).<br />If the user was a Practitioner, this value would be `Practitioner/123`
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

