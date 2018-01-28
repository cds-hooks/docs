# Hooks

## Overview

As a specification, CDS Hooks does not prescribe a default or required set of hooks for implementers. Rather, the set of hooks defined here are merely a set of common use cases that were used to aid in the creation of CDS Hooks. The set of hooks defined here are not a closed set; anyone is able to define new hooks to fit their use cases.

New hooks should be added to the CDS [proposed hooks Wiki page](https://github.com/cds-hooks/docs/wiki/Proposed-Hooks) according to the format described below.

Note that each hook (e.g. `medication-prescribe`) represents something the user is doing in the EHR and multiple CDS Services might respond to the same hook (e.g. a "price check" service and a "prior authorization" service might both respond to `medication-prescribe`).

## Hook context and prefetch

### What's the difference?

A discrete user workflow or action within the EHR often naturally includes a set of contextual data. This context can contain both required and optional data and is specific to a hook. Additionally, the context data is relevant to most CDS Services subscribing to the hook.

When the context data relates to a FHIR data type, it is important not to conflate context and prefetch. For instance, imagine a hook for opening a patient's chart. This hook should include the FHIR identifier of the patient whose chart is being opened, not the full patient FHIR resource. In this case, the FHIR identifier of the patient is appropriate as CDS Services may not be interested in details about the patient resource but instead other data related to this patient. Or, a CDS Service may only need the full patient resource in certain scenarios. Therefore, including the full patient resource in context would be unnecessary. For CDS Services that want the full patient resource, they can request it to be prefetched or fetch it as need from the FHIR server.

Consider another hook for when a new patient is being registered. In this case, it would likely be appropriate for the context to contain the full FHIR resource for the patient being registered as the patient may not be yet recorded in the EHR (and thus not available from the FHIR server) and CDS Services using this hook would predominately be interested in the details of the patient being registered.

In summary, context is data specific to a hook and universally relevant to all CDS Services subscribed to said hook. Prefetch data is unique to individual CDS Services and supplements the data from context.

### Prefetch tokens

Often a prefetch template builds on the contextual data associated with the hook. For example, a particular CDS Service might recommend guidance based on a patient's conditions when the chart is opened. The FHIR query to retrieve these conditions might be `Condition?patient=123`. In order to express this as a prefetch template, the CDS Service must express the FHIR identifier of the patient as a token so that the EHR can replace the token with the appropriate value. When context fields are used as tokens, their token name MUST be `context.name-of-the-field`. For example, given a context like:

```json
"context" : {
  "patientId": "123"
}
```

The token name would be `{{context.patientId}}`. Again using our above conditions example, the complete prefetch template would be `Condition?patient={{context.patientId}}`.

Only the first level fields in context may be considered for tokens. Hook creators MUST document which fields in the context are supported as tokens. If a context field can be tokenized, the value of the context field MUST be a data type that can placed into a FHIR query (eg, string, number, etc).

## Hook Definition Format

Hooks are defined in the following format:

-----

# `hook-name-expressed-as-noun-verb` 

The name of the hook SHOULD succinctly and clearly describes the activity or event. Hook names are unique so hook creators SHOULD take care to ensure newly proposed hooks do not conflict with an existing hook name. Hook creators MAY choose to name their hook with a URI (e.g. `https://example.org/hooks/patient-transmogrify`) if the hook is specific to an organization.

When naming hooks, the name should start with the subject (noun) of the hook and be followed by the activity (verb). For example, `patient-view` (not `view-patient`) or `medication-prescribe` (not `prescribe-medication`).

## Workflow

Describe when this hook occurs in a workflow. Hook creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementors.

## Context

Describe the set of contextual data used by this hook. Only data logically and necessarily associated with the purpose of this hook should be represented in context.

All fields defined by the hook's context MUST be defined in a table where each field is described by three attributes:

- Field: The name of the property in the context JSON object.
- Priority: A fixed value of either `REQUIRED` or `OPTIONAL`
- Prefetch Token: A fixed value of either `Yes` or `No`, indicating whether this field can be tokenized in a prefetch template.
- Description: The value of the property in the context JSON object, expressed both as the JSON data type as well as a functional description of the value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

While a context with FHIR data SHOULD document any differences in the data between FHIR versions, when a context object is valued, all FHIR resources in context MUST be based on the same FHIR version.

Field | Priority | Prefetch Token | Description
----- | -------- | ---- | ----
`someProperty` | REQUIRED | Yes | *string* A clear description of the value of this field.
`anotherProperty` | OPTIONAL | No | *number* A clear description of the value of this field.
`someObject` | REQUIRED | No | *object* A clear description of the value of this field.
`moreObjects` | OPTIONAL | No | *array* A clear description of the items in this array.

### Examples

Hook creators SHOULD include examples of the context.

```json
"context":{
  "someProperty":"foo",
  "anotherProperty":123,
  "someObject": {
    "color": "red",
    "version": 1
  },
  "moreObjects":[]
}
```

If the context contains FHIR data, hook creators SHOULD include examples across multiple versions of FHIR if differences across FHIR versions are possible.
