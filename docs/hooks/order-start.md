`order-start`

This page defines a workflow [hook](../../specification/current/#hooks) for the purpose of providing clinical decision support using CDS Hooks. This is a build at the level of [Draft](http://hl7.org/fhir/versions.html#std-processs).

| Metadata | Value
| ---- | ----
| specificationVersion | 2.0
| hookVersion | 0.1.0
| hookMaturity | [0 - Draft](../../specification/current/#hook-maturity-model)

## Workflow

The `order-start` hook fires when the clinician has reached the point in the workflow where they are ready to begin adding new orders (including orders for medications, procedures, labs and other orders) for the patient. This point in the workflow will usually occur during the encounter when the clinician has completed the examination and assessment, but before they have searched for or selected a given order. 

## Context

Post-order alert/change has been determined a major cause of alert fatigue and is cited specifically in studies on physician burnout. The purpose of the hook is to allow guidance services to make order recommendations to the clinician at the point where sufficient clinical data for the patient has been collected but before any orders have been selected.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user is expected to be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html) or [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html).<br>For example, `PractitionerRole/123` or `Practitioner/abc`.
`patientId` | REQUIRED | Yes | *string* |  The FHIR `Patient.id` of the current patient in context
`encounterId` | REQUIRED | No | *string* |  The FHIR `Encounter.id` of the current encounter in context

## Prefetch
CDS clients should consider including the patient's current active problems, current medication list, lab results, allergy/intolerance and patient goal information as prefetch data. Given that these items will necessarily vary, they should all be considered as optional values.

Field | Type | Description
----- | ---- | ----
`patient` | *object* | The patient's demographic information. A FHIR Patient.
`conditions` | *object* | The patient's current active problems. A FHIR Bundle of Condition.
`medications` | *object* | The patient's current active medications.  <br> DSTU2/STU3 - A FHIR Bundle of MedicationStatement. <br> R4/R5 - A FHIR Bundle of MedicationRequest.
`observations` | *object* | The patient's most recent lab results, vitals and social history observations. A FHIR Bundle of Observation.
`allergyintolerances` | *object* | The patient's active allergies and intolerances. A FHIR Bundle of AllergyIntolerance.
`goals` | *object* | The patient's goals. A FHIR Bundle of Goal.
 

## Examples

### Example (R4) (context)

```json
{
   "context":{
      "userId":"Practitioner/123",
      "patientId":"12345",
      "encounterId":"98765",
         }
}
```
## Example (R4) (prefetch)
```json
{
   "prefetch": {
        "patient": "Patient/{{context.patientId}}",
        "conditions": "Condition?patient={{context.patientId}}&category=problem-list",
        "medications": "MedicationRequest?patient={{context.patientId}}",
        "observations": "Observation?patient={{context.patientId}}&category=vital-signs,laboratory,social-history",
        "allergyintolerances": "AllergyIntolerance?patient={{context.patientId}}",
        "goal": "Goal?patient={{context.patientId}}"
      }
}
```

## Change Log
Version | Description
---- | ----
0.1.0 | Proposed










































































































































