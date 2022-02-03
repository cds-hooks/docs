# <mark>`order-dispatch`</mark>

| Metadata | Value
| ---- | ----
| specificationVersion | 2.0
| hookVersion | 1.0
| hookMaturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

The `order-dispatch` hook fires when a practitioner is selecting a candidate performer for a pre-existing order that was not tied to a specific performer.  For example, selecting an imaging center to satisfy a radiology order, selecting a cardiologist to satisfy a referral, etc.  This hook only occurs in situations where the order is agnostic as to who the performer should be and a separate process (which might be performed by back-office staff, a central dispatch service, or even the ordering clincian themselves at a later time) is used to select and seek action by a specific performer.  It is possible that the same order might be dispatched multiple times, either because initial selected targets refuse or are otherwise unable to satisfy the order, or because the performer is only asked to perform a 'portion' of what's authorized (the first monthly lab test of a year-long set, the first dispense of a 6 month order, etc.)

This "request for fulfillment" process is typically represented in FHIR using [Task](http://hl7.org/fhir/task.html).  This resource allows indication of the order to be acted upon, who is being asked to act on it, the time-period in which they're expected to act, and any limitations/qualifications to how much of the order should be acted on.

Decision support that may be relevant for this hook might include information related to coverage, prior-authorization and/or in-network/out-of-network evaluations with respect to the chosen performer; determination of practitioner availability or qualification; enforcement/guidance with respect to patient performer practitioners; etc.

## Context

<mark>Define context values that are available when this hook occurs, and indicate whether they must be provided, and whether they are available for parameterizing prefetch templates.</mark>

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`task` | REQUIRED | No | *object* | DSTU2/STU3/R4 - Task instance with code of 'fulfill'

### Examples

```json
"context":{
  "patientId" : "1288992",
  "task" : {
    "resourceType" : "Task",
    "status" : "draft",
    "intent" : "order",
    "code" : {
      "coding" : [{
        "system" : "",
        "code" : ""
      }]
    },
    "focus" : {
      "reference" : "MedicationRequest/medrx002"
    },
    "for" : {
      "reference" : "Patient/1288992"
    },
    "authoredOn" : "2016-03-10T22:39:32-04:00",
    "lastModified" : "2016-03-10T22:39:32-04:00",
    "requester": {
      "reference" : "Practitioner/123"
    },
    "owner" : {
      "reference" : "Organziation/some-pharmacy"
    }
  }
}
```

```json
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
