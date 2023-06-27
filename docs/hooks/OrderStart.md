`order-start`

!!! info
    This page defines a workflow [hook](../../specification/current/#hooks) for the purpose of providing clinical decision support using CDS Hooks. This is a build at the level of [Draft](http://hl7.org/fhir/versions.html#std-processs).

| Metadata | Value
| ---- | ----
| specificationVersion | 2.0
| hookVersion | 0.1.0
| hookMaturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

The `order-start` hook fires when the clinician has reached the point in the workflow where they are ready to begin adding new orders (including orders for medications, procedures, labs and other orders) for the patient. This point in the workflow will usually occur during the encounter when the clinician has completed the examination and assessment, but before they have searched for or selected a given order. The purpose of the hook is to allow guidance services to make order recommendations to the clinician at the point where sufficient clinical data for the patient has been collected but before any orders have been selected.  

## Context
CDS Services should consider including the patient's current active problems, current medication list, lab results, and allergy/intolerance information as prefetch data. Given that these items will necessarily vary they should all be considered as optional values. 

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html) or [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html).<br />For example, `PractitionerRole/123` or `Practitioner/abc`.
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | REQUIRED | Yes | *string* |  The FHIR `Encounter.id` of the current encounter in context
`activeProblems` | OPTIONAL | No| *object* | FHIR Bundle with the patient's current active problems.  <br/ > DSTU2 - FHIR Bundle of Condition. <br/ > STU3 - FHIR Bundle of Condition. <br/ > R4 - FHIR Bundle of Condition. <br/ > R5 - FHIR Bundle of Condition.
`activeMedications` | OPTIONAL | No| *object* | FHIR Bundle with the patient's current active medications.  <br/ > DSTU2 - FHIR Bundle of MedicationStatement. <br/ > STU3 - FHIR Bundle of MedicationStatement. <br/ > R4 - FHIR Bundle of MedicationRequest. <br/ > R5 - FHIR Bundle of MedicationRequest.
`labResults` | OPTIONAL | No| *object* | FHIR Bundle with the patient's most recent lab results.  <br/ > DSTU2 - FHIR Bundle of Observation. <br/ > STU3 - FHIR Bundle of Observation. <br/ > R4 - FHIR Bundle of Observation. <br/ > R5 - FHIR Bundle of Observation.
`patientAllergyIntolerances` | OPTIONAL | No| *object* | FHIR Bundle with the patient's active allergies and intolerances.  <br/ > DSTU2 - FHIR Bundle of AllergyIntolerance. <br/ > STU3 - FHIR Bundle of AllergyIntolerance. <br/ > R4 - FHIR Bundle of AllergyIntolerance. <br/> R5 - FHIR Bundle of AllergyIntolerance.
 

## Examples

### Example (R4)

```json
{
   "context":{
      "userId":"PractitionerRole/123",
      "patientId":"12345",
      "encounterId":"98765",
         }
}
```
## Change Log
Version | Description
---- | ----
0.1.0 | Proposed










































































































































