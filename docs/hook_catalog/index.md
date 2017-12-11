# Hook Catalog

## Pre-defined CDS hooks

We describe a set of hooks to support common use cases out of the box. But **this is not a closed set**; anyone can define new hooks to address new use cases. To propose a new hooks please add it to the [proposed hooks](https://github.com/cds-hooks/docs/wiki/Proposed-Hooks) page of our wiki in the same format as below.

Note that each hook (e.g. `medication-prescribe`) represents something the user is doing in the EHR; various CDS services might respond to the same hook (e.g. a "price check" service and a "prior authorization" service might both respond to `medication-prescribe`).

Note also that each hook name in our official catalog is a simple string. If you want to define custom hooks without submitting them to the catalog, then you should use a URI (e.g. `http://my-organization/custom-hooks/patient-transmogrify`).

## Hook context and prefetch

### What's the difference?
A discrete user workflow or action within the EHR often naturally includes a set of contextual data. For example, the patient-view hook necessarily includes a patient. For many clinical workflows, the patient-view also includes an encounter. These pieces of contextual data naturally define the hook and are generically useful for most CDS services subscribing to the hook.  Each pre-defined CDS hook may include one or more required or optional contextual parameters represented as named key/value pairs. 

Pre-fetch, on the other hand, defines data that is used and perhaps even required, by a single CDS service. 

### Pre-fetch extends context.
Often a pre-fetch template builds on the contextual data associated with the CDS hook. For example, a particular CDS service might recommend guidance based on a patient's conditions when the chart is opened. The service could obtain the patient's conditions with a FHIR search, like so:  `Condition?patient=patient123`. 
Since the hook's contextual parameters are named, the pre-fetch template references the actual name of the contextual value from the CDS request. Using the below example hook definition, and actual prefetch template would be: `Condition?patient={{example-patient-id}}`.

**Format for hook definitions**:

New hooks are defined in the following format. Note that all FHIR resources in a single CDS request should be the same version of FHIR. 

# `hook-name-expressed-as-noun-verb` 
The hook name is a simple string that succintly describes the user's action. 

## **Workflow description**
Describe this hook occurs in a user's workflow.

## **Contextual data**
Describe the set of contextual data required for this hook as represented by FHIR resources, including FHIR version and complete example. Only data logically and necessarily associated with the user's action should be represented in context; prefetch should enable any additional data required in the request by a specific cds service.

|key|data|required?|
|---|---|---|
|json object name|description of object value, e.g. <br/> FHIR version - [Array of] FHIR resource <br/> FHIR resource id <br/> non-FHIR object|
|example-patient-id|Patient FHIR id|Yes|
|example-medication|DSTU2 - MedicationOrder <br/>STU3 - MedicationRequest|No|


```json
{
  "context": {
	"example-patient-id" : {
		// FHIR patient identifier
	},
    "example-medication": {
		// DSTU2: full MedicationOrder FHIR resource of the medication being prescribed or, 
		// STU3: full MedicationRequest FHIR resource of the medication being prescribed
	}
  }
}
```