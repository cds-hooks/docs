`order-discontinue`

!!! info
    This page defines a workflow [hook](../../specification/current/#hooks) for the purpose of providing clinical decision support using CDS Hooks. This is a <mark>**build | snapshot | ballot | release**</mark> at the level of <mark>**[Draft](http://hl7.org/fhir/versions.html#std-processs)**</mark>

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 0.1.0
| hookMaturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

The `order-discontinue` fires when a signed order is discontinued by a clinician (including orders for medications, procedures, labs and other orders).

## Context
CDS Services should consider retreiving or prefetch'ing the `toBeDiscontinued` order, and should focus decisions support on the discontinuation of this order.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html) or [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html).<br />For example, `PractitionerRole/123` or `Practitioner/abc`.
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | OPTIONAL | Yes | *string* |  The FHIR `Encounter.id` of the current encounter in context
`toBeDiscontinued` | REQUIRED | No| *array* | The FHIR id of one or more existing order(s) in the procss of being discontinued.<br /> For example, `MedicationRequest/103`.

## Examples

### Example (R4)

```json
{
   "context":{
      "userId":"PractitionerRole/123",
      "patientId":"1288992",
      "encounterId":"89284",
      "toBeDiscontinued": [ "MedicationRequest/smart-MedicationRequest-103" ]
   }
}
```


## Change Log

Version | Description
---- | ----
0.1.0 | Proposed
