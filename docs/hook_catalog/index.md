# Hook Catalog

## Pre-defined CDS hooks

We describe a set of hooks to support common use cases out of the box. But **this is not a closed set**; anyone can define new hooks to address new use cases. To propose a new hooks please add it to the [proposed hooks](https://github.com/cds-hooks/docs/wiki/Proposed-Hooks) page of our wiki in the same format as below.

Note that each hook (e.g. `medication-prescribe`) represents something the user is doing in the EHR; various CDS services might respond to the same hook (e.g. a "price check" service and a "prior authorization" service might both respond to `medication-prescribe`).

Note also that each hook name in our official catalog is a simple string. If you want to define custom hooks without submitting them to the catalog, then you should use a URI (e.g. `http://my-organization/custom-hooks/patient-transmogrify`).

## Format for hook definitions

### `hook-name-expressed-as-noun-verb` 
The hook name is a simple string that succintly describes the user's action. 

**Purpose**: (Describe this hook occurs in a user's workflow.)

**Context**: (Describe the set of contextual data required for this hook as represented by FHIR resources, including FHIR version and complete example. Only data logically and necessarily associated with the user's action should be represented in context; prefetch should enable any additional data required in the request by a specific cds service).

|key|data|FHIR resource version|
|---|---|---|
|json object name|FHIR resource name or FHIR resource identifier|FHIR resource version(s)|

```json
{
  "context": {
	"patient" : {
		// DSTU2: full Patient FHIR resource for the patient currently in context or , 
		// STU3: full Patient FHIR resource for the patient currently in context
	},
    "medication": {
		// DSTU2: full MedicationOrder FHIR resource of the medication being prescribed or, 
		// STU3: full MedicationRequest FHIR resource of the medication being prescribed
	}
  }
}