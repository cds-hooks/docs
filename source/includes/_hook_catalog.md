# Hook Catalog

## Pre-defined CDS hooks

We describe a set of hooks to support common use cases out of the box.
But **this is not a closed set**; anyone can define new hooks to address new use
cases. To propose a new hooks please add it to the [proposed hooks](https://github.com/cds-hooks/docs/wiki/Proposed-Hooks) page of our wiki.

Note that each hook (e.g. `medication-prescribe`) represents something the user is doing in the EHR; various hooks might respond to the same hook (e.g. a "price check" service and a "prior authorization" service might both respond to `medication-prescribe`).

Note also that each hook name in our official catalog is a simple string. If
you want to define custom hooks without submitting them to the catalog, then
you should use a URI (e.g.
`http://my-organization/custom-hooks/patient-transmogrify`).


## `medication-prescribe`


```json
{
  "context": {
    "resourceType": "MedicationOrder",
    "medicationCodeableConcept": {
      "...": "<snipped for brevity>"
    }
  }
}
```

**Purpose**: Inform an external CDS service that the user is in the process of
prescribing a new medication, and solicit feedback about the
prescription-in-progress.

**Contextual data**: The set of proposed medication prescriptions. using the
FHIR `MedicationOrder` resource. See example in the sidebar.

## `order-review`

```json
{
  "context": {
    "resourceType": "DiagnosticOrder",
    "...": "<snipped for brevity>"
  }
}
```

**Purpose**: Inform an external CDS service that the user is in the process of
reviewing a set of orders (sometimes known as a "shopping cart"), and solicit
feedback about the orders being reviewed.




**Contextual data**: The set of orders being reviewed on-screen, represented
using a combination of MedicationOrder, DiagnosticOrder, DeviceUseRequest,
ReferralRequest, and ProcedureRequest. See example in the sidebar.

## `patient-view`

**Purpose**: Inform an external CDS service that the user has just opened a new
patient record and is viewing a summary screen or "face sheet", and solicit
feedback about this patient.

**Contextual data**: None required beyond default context.
