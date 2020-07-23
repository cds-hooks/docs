# `order-search`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0
| hookMaturity | [0 - Draft](../../specification/1.0/#hook-maturity-model)

## Workflow

The `order-search` hook fires when a clinician has decided a patient needs an order (including orders for medications, procedures, labs or other orders), and is searching to find an appropriate one in the order catalogue of the CPOE.
This hooks is the first workflow event when browsing the catalogue of the CPOE.

The context of this hook must include the type of order that is being searched.

The `order-search` hooks occurs before the `order-select` hook, where a clinician has already selected a specific order but not necessarily the all of the parameters such as how much or how often.

## Context

The `orderType` parameter allows decision services to be run that are appropriate for the current clinical context. There are many types of orders within FHIR and without this additional context a clinician could inadvertently get `DeviceRequest` recommendations while searching for `ServiceRequests`. Prefetch is not an appropriate place for this context because it is optional, and the decision support system may query for additional resources that are not relevant to the current clinical context.


Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html).<br />For example, `Practitioner/123`
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* |  The FHIR `Encounter.id` of the current encounter in context
`orderType` | REQUIRED | No | *string* | The FHIR Resource type of the current search. For example, `DeviceRequest`

### Examples

```json
"context":{
  "userId": "Practitioner/123",
  "patientId" : "1288992",
  "orderType" : "MedicationRequest"
}
```

```json
"context":{
  "userId": "Practitioner/123",
  "patientId" : "1288992",
  "encounterId" : "456",
  "orderType": "ServiceRequest"
}
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release
