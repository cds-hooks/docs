# `patient-view`

## Workflow description

The user has just opened a patient's record.

## Context

The patient whose record was opened.

Field | Priority | Prefetch Token | Description
----- | -------- | ---- | ----
`patientId` | REQUIRED | No | *string*. The FHIR `Patient.id` of the current patient in context

### Example (DSTU2)

```json
"context":{
  "patientId" : "1288992"
}
```

