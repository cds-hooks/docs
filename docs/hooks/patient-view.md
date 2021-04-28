# `patient-view`

!!! info
    This page defines a workflow [hook](../../specification/current/#hooks) for the purpose of providing clinical decision support using CDS Hooks version 1.0. This is a **build** at the level of **[Trial Use](http://hl7.org/fhir/versions.html#std-processs)**.

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0
| hookMaturity | [5 - Mature](../../specification/1.0/#hook-maturity-model)

## Workflow

The user has just opened a patient's record.

## Context

The patient whose record was opened, including their encounter, if applicable.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For example, if the user represents a FHIR resource on the given FHIR server, the resource type would be one of [Practitioner](https://www.hl7.org/fhir/practitioner.html), [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html), [Patient](https://www.hl7.org/fhir/patient.html), or [RelatedPerson](https://www.hl7.org/fhir/relatedperson.html).<br /> Patient or RelatedPerson are appropriate when a patient or their proxy are viewing the record.
`patientId` | REQUIRED | Yes | *string* | The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* | The FHIR `Encounter.id` of the current encounter in context

### Examples

```json
"context":{
  "userId" : "PractitionerRole/123",
  "patientId" : "1288992"
}
```

```json
"context":{
  "userId" : "Practitioner/abc",
  "patientId" : "1288992",
  "encounterId" : "456"
}
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
