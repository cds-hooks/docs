# `patient-view`

## Workflow description

The user has just opened a patient's record.

## Context

The patient whose record was opened, including their encounter, if applicable.

Field | Priority | Prefetch Token | Description
----- | -------- | ---- | ----
`patientId` | REQUIRED | Yes | *string*. The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string*. The FHIR `Encounter.id` of the current encounter in context

### Examples

```json
"context":{
  "patientId" : "1288992"
}
```

```json
"context":{
  "patientId" : "1288992",
  "encounterId" : "456"
}
```