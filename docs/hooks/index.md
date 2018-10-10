# Hooks

## Overview

As a specification, CDS Hooks does not prescribe a default or required set of hooks for implementers. Rather, the set of hooks defined here are merely a set of common use cases that were used to aid in the creation of CDS Hooks. The set of hooks defined here are not a closed set; anyone is able to define new hooks to fit their use cases.

New hooks should be added to the CDS [proposed hooks Wiki page](https://github.com/cds-hooks/docs/wiki/Proposed-Hooks) according to the format described below. A [template](template) hook definition is included as a starting point for new hooks.

Note that each hook (e.g. `medication-prescribe`) represents something the user is doing in the EHR and multiple CDS Services might respond to the same hook (e.g. a "price check" service and a "prior authorization" service might both respond to `medication-prescribe`).

## Hook context and prefetch

### What's the difference?

A discrete user workflow or action within the EHR often naturally includes a set of contextual data. This context can contain both required and optional data and is specific to a hook. Additionally, the context data is relevant to most CDS Services subscribing to the hook.

When the context data relates to a FHIR data type, it is important not to conflate context and prefetch. For instance, imagine a hook for opening a patient's chart. This hook should include the FHIR identifier of the patient whose chart is being opened, not the full patient FHIR resource. In this case, the FHIR identifier of the patient is appropriate as CDS Services may not be interested in details about the patient resource but instead other data related to this patient. Or, a CDS Service may only need the full patient resource in certain scenarios. Therefore, including the full patient resource in context would be unnecessary. For CDS Services that want the full patient resource, they can request it to be prefetched or fetch it as needed from the FHIR server.

Consider another hook for when a new patient is being registered. In this case, it would likely be appropriate for the context to contain the full FHIR resource for the patient being registered as the patient may not be yet recorded in the EHR (and thus not available from the FHIR server) and CDS Services using this hook would predominantly be interested in the details of the patient being registered.

Additionally, consider a PGX CDS Service and a Zika screening CDS Service, each of which is subscribed to the same hook. The context data specified by their shared hook should contain data relevant to both CDS Services; however, each service will have other specific data needs that will necessitate disparate prefetch requests. For instance, the PGX CDS Service likely is interested in genomics data whereas the Zika screening CDS Service will want Observations.

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

For example, given the following context that contains amongst other things, a Patient FHIR resource:

```json
"context" : {
  "encounterId": "456",
  "patient": {
    "resourceType": "Patient",
    "id": "123",
    "active": true,
    "name": [
      {
        "use": "official",
        "family": "Watts",
        "given": [
          "Wade"
        ]
      }
    ],
    "gender": "male",
    "birthDate": "2024-08-12"
  }
}
```

Only the `encounterId` field in this example is eligible to be a prefetch token as it is a first level field and the datatype (string) can be placed into the FHIR query. The Patient.id value in the context is not eligible to be a prefetch token because it is not a first level field. If the hook creator intends for the Patient.id value to be available as a prefetch token, it must be made available as a first level field. Using the aforementioned example, we simply add a new `patientId` field:

```json
"context" : {
  "patientId": "123",
  "encounterId": "456",
  "patient": {
    "resourceType": "Patient",
    "id": "123",
    "active": true,
    "name": [
      {
        "use": "official",
        "family": "Watts",
        "given": [
          "Wade"
        ]
      }
    ],
    "gender": "male",
    "birthDate": "2024-08-12"
  }
}
```

## Hook Definition Format

Hooks are defined in the following format.

### `hook-name-expressed-as-noun-verb`

The name of the hook SHOULD succinctly and clearly describe the activity or event. Hook names are unique so hook creators SHOULD take care to ensure newly proposed hooks do not conflict with an existing hook name. Hook creators SHALL name their hook with reverse domain notation (e.g. `org.example.patient-transmogrify`) if the hook is specific to an organization. Reverse domain notation SHALL not be used by a standard hooks catalog.

When naming hooks, the name should start with the subject (noun) of the hook and be followed by the activity (verb). For example, `patient-view` (not `view-patient`) or `medication-prescribe` (not `prescribe-medication`).

### Workflow

Describe when this hook occurs in a workflow. Hook creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementors.

### Context

Describe the set of contextual data used by this hook. Only data logically and necessarily associated with the purpose of this hook should be represented in context.

All fields defined by the hook's context MUST be defined in a table where each field is described by the following attributes:

- Field: The name of the field in the context JSON object.
- Optionality: A string value of either `REQUIRED` or `OPTIONAL`
- Prefetch Token: A string value of either `Yes` or `No`, indicating whether this field can be tokenized in a prefetch template.
- Type: The type of the field in the context JSON object, expressed as the JSON type, or the name of a FHIR Resource type. Valid types are *boolean*, *string*, *number*, *object*, *array*, or the name of a FHIR resource type. When a field can be of multiple types, type names MUST be separated by a *pipe* (`|`)
- Description: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

The below illustrates a sample table. 

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`someField` | REQUIRED | Yes | *string* | A clear description of the value of this field.
`anotherField` | OPTIONAL | No | *number* | A clear description of the value of this field.
`someObject` | REQUIRED | No | *object* | A clear description of the value of this field.
`moreObjects` | OPTIONAL | No | *array* | A clear description of the items in this array.
`allFHIR` | OPTIONAL | No | *object* | A FHIR Bundle of the following FHIR resources using a specific version of FHIR.

### FHIR resources in context

When potentially multiple FHIR resources value a single context field, these resources SHOULD be formatted as a FHIR Bundle. For example, multiple FHIR resources are necessary to describe all of the orders under review in the `order-review` hook's `orders` field. Hook definitions SHOULD prefer the use of FHIR Bundles over other bespoke data structures.

Often, context is populated with in-progress or in-memory data that may not yet be available from the FHIR server. For example, `medication-prescribe` and `order-review` define context fields containing FHIR resources that represent draft resources. In this case,  the EHR should only provide these draft resources and not the full set of orders available from its FHIR server. The CDS service MAY pre-fetch or query for FHIR resources with other statuses. 

All FHIR resources in context MUST be based on the same FHIR version. 

### Examples

Hook creators SHOULD include examples of the context.

```json
"context":{
  "someField":"foo",
  "anotherField":123,
  "someObject": {
    "color": "red",
    "version": 1
  },
  "moreObjects":[]
}
```

If the context contains FHIR data, hook creators SHOULD include examples across multiple versions of FHIR if differences across FHIR versions are possible.

## Hook Maturity Model
The intent of the CDS Hooks Maturity Model is to attain broad community engagement and consensus, before a hook is labeled as mature, that the hook is necessary, implementable, and worthwhile to the CDS services and CDS clients that would reasonably be expected to use it. Implementer feedback should drive the maturity of new hooks. Diverse participation in open developer forums and events, such as HL7 FHIR Connectathons, is necessary to achieve significant implementer feedback. The below criteria will be evaluated with these goals in mind.

The Hook maturity levels use the term CDS client to generically refer to the clinical workflow system in which a CDS services returned cards are displayed. 

Maturity Level | Maturity title | Requirements
--- | --- | ---
0 | Draft | Hook is defined according to the [hook definition format](#hook-definition-format). 
1 | Submitted  | _The above, and …_ Hook definition is written up as a github pull request using the [Hook template](hooks/template/) and community feedback is solicited on the [zulip CDS Hooks stream](https://chat.fhir.org/#narrow/stream/17-cds-hooks). (TODO - specify repo that PR should be submitted to).
2 | Tested | _The above, and …_ The hook has been tested and successfully supports interoperability among at least one CDS client and two independent CDS services using semi-realistic data and scenarios (e.g. at a FHIR Connectathon). The github pull request defining the hook is approved and published.
3 | Considered |  _The above, and …_ At least 3 distinct organizations recorded ten distinct implementer comments (including a github issue, tracker item, or comment on the hook definition page), including at least two CDS clients and three independent CDS services. The hook has been tested at two connectathons.
4 | Documented | _The above, and …_ The author agrees that the artifact is sufficiently stable to require implementer consultation for subsequent non-backward compatible changes.  The hook is implemented in the standard CDS Hooks sandbox and multiple prototype projects. The Hook specification SHALL: <ul><ol>Identify a broad set of example contexts in which the hook may be used with a minimum of three, but as many as 8-10.</ol><ol>Clearly differentiate the hook from similar hooks or other standards to help an implementer determine if the hook is correct for their scenario.</ol><ol>Explicitly document example scenarios when the hook should not be used.</ol></ul>
5 | Mature | _The above, and ..._ The hook has been implemented in production in at least two CDS clients and three independent CDS services. An HL7 working group ballots the hook and the hook has passed HL7 STU ballot.
6 | Normative | _The above, and ..._ the responsible HL7 working group and the CDS working group agree the material is ready to lock down and the hook has passed HL7 normative ballot


## Changes to the Definition of a Hook (Hook Versioning)

Each hook MUST include a Metadata table at the beginning of the hook with the specification version and hook version as described in the following sections.

### Specification Version

Because hooks are such an integral part of the CDS Hooks specification, hook definitions are associated with specific versions of the specification. The hook definition MUST include the version (or versions) of the CDS Hooks specification that it is defined to work with.

    specificationVersion | 1.0

Because the specification itself follows semantic versioning, the version specified here is a minimum specification version. In other words, a hook defined to work against 1.0 should continue to work against the 1.1 version of CDS Hooks. However, a hook that specifies 1.1 would not be expected to work in a CDS Hooks 1.0 environment.

### Hook Version

To enable tracking of changes to hook definitions, each hook MUST include a version indicator, expressed as a string.

    hookVersion | 1.0

To help ensure the stability of CDS Hooks implementations, once a hook has been defined (i.e. published with a particular name so that it is available for implementation), breaking changes MUST NOT be made. This means that fields can be added and restrictions relaxed, but fields cannot be changed, and restrictions cannot be tightened.

In particular, the semantics of a hook (i.e. the meaning of the hook from the perspective of the EHR) cannot be changed. EHRs that implement specific hooks are responsible for ensuring the hook is called from the appropriate point in the workflow.

Note that this means that the name of the hook carries major version semantics. That is not to say that the name must include the major version, that is left as a choice to authors of the specification. For example, following version 1.x, the major version MAY be included in the name as "-2", "-3", etc. Eg: patient-view-2, patient-view-3, etc. Clean hook names increase usability. Ideally, an active hook name accurately defines the meaning and workflow of the hook in actual words.

The following types of changes are possible for a hook definition:

Change | Version Impact
------ | ----
Clarifications and corrections to documentation that do not impact functionality | Patch
Change of prefetch token status of an existing context field | Patch
Addition of a new, REQUIRED field to the context | Major
Addition of a new, OPTIONAL field to the context | Minor
Change of optionality of an existing context field | Major
Change of type or cardinality of an existing context field | Major
Removal of an existing context field | Major
Change of semantics of an existing context field | Major
Change of semantics of the hook | Major

When a major change is made, the hook definition MUST be published under a new name. When a minor or patch change is made, the hook version MUST be updated. Hook definers MUST use [semantic versioning](https://semver.org/) to communicate the impact of changes in an industry standard way.

### Change Log

Changes made to a hook MUST be documented in a change log to ensure hook consumers can track what has been changed over the life of a hook. The change log MUST contain the following elements:

- Version: The version of the change
- Description: A description of the change and its impact

For example:

Version | Description
---- | ----
1.1 | Added new context variable
1.0.1 | Clarified context variable usage
1.0 | Initial Release




