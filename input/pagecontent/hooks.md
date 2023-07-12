## Hooks

### Overview

As a specification, CDS Hooks does not prescribe a default or required set of hooks for implementers. Rather, the set of hooks defined here are merely a set of common use cases that were used to aid in the creation of CDS Hooks. The set of hooks defined here are not a closed set; anyone is able to define new hooks to fit their use cases and propose those hooks to the community. New hooks are proposed in a prescribed [format](#hook-definition-format) using the [documentation template](https://github.com/cds-hooks/docs/wiki/Proposed-Hooks) by submitting a [pull request](https://github.com/cds-hooks/docs/tree/master/docs/hooks) for community feedback. Hooks are [versioned](#hook-version), and mature according to the [Hook Maturity Model](#hook-maturity-model).

Note that each hook (e.g. `order-select`) represents something the user is doing in the CDS Client and multiple CDS Services might respond to the same hook (e.g. a "price check" service and a "prior authorization" service might both respond to `order-select`).

### Hook context and prefetch

#### What's the difference?

Any user workflow or action within a CDS Client will naturally include contextual information such as the current user and patient. CDS Hooks refers to this information as _context_ and allows each hook to define the information that is available in the context. Because CDS Hooks is intended to support usage within any CDS Client, this context can contain both required and optional data, depending on the capabilities of individual CDS Clients. However, the context information is intended to be relevant to most CDS Services subscribing to the hook.

For example, consider a simple `patient-view` hook that is invoked whenever the user views a patient's information within the CDS Client. At this point in the workflow, the contextual information would include at least the current user and the patient that is being viewed. The hook declares this as `context`, and passes it to the CDS Service as part of the request in the `context` field:

```json
"context":{
  "userId" : "PractitionerRole/123",
  "patientId" : "1288992"
}
```

Prefetch data, on the other hand, is defined by CDS Services as a way to allow the CDS Client to provide the data that a CDS Service needs as part of the initial request to the service. When the context data relates to a FHIR resource, it is important not to conflate context and prefetch. For instance, in the hook described above for opening a patient's chart, the hook context includes the id of the patient whose chart is being opened, not the full patient FHIR resource. In this case, the FHIR id of the patient is appropriate as the CDS Services may not be interested in details from the patient resource but instead other data related to this patient. Therefore, including the full patient resource in context would be unnecessary.
Alternatively, a CDS Service may need the full patient resource in certain scenarios, in which case they can fetch it as needed from the FHIR server or request it to be prefetched using a prefetch template in their discovery response, such as:

```json
"prefetch": {
  "patientToGreet": "Patient/{{context.patientId}}"
}
```

See the section on [prefetch tokens](services.html#prefetch-tokens) for more information on how contextual information can be used to parameterize prefetch templates.

Consider another hook for when a new patient is being registered. In this case, it would likely be appropriate for the context to contain the full FHIR resource for the patient being registered as the patient may not be yet recorded in the CDS Client (and thus not available from the FHIR server) and CDS Services using this hook would predominantly be interested in the details of the patient being registered.

Additionally, consider a PGX CDS Service and a Zika screening CDS Service, each of which is subscribed to the same hook. The context data specified by their shared hook should contain data relevant to both CDS Services; however, each service will have other specific data needs that will necessitate disparate prefetch requests. For instance, the PGX CDS Service likely is interested in genomics data whereas the Zika screening CDS Service will want Observations.

In summary, context is specified in the hook definition to guide developers on the information available at the point in the workflow when the hook is triggered. Prefetch data is defined by each CDS Service because it is specific to the information that service needs in order to process.

### Hook Definition Format

Hooks are defined in the following format.

#### `hook-name-expressed-as-noun-verb`

The name of the hook SHOULD succinctly and clearly describe the activity or event. Hook names are unique so hook creators SHOULD take care to ensure newly proposed hooks do not conflict with an existing hook name. Hook creators SHALL name their hook with reverse domain notation (e.g. `org.example.patient-transmogrify`) if the hook is specific to an organization. Reverse domain notation SHALL not be used by a standard hooks catalog.

When naming hooks, the name should start with the subject (noun) of the hook and be followed by the activity (verb). For example, `patient-view` (not `view-patient`) or `order-sign` (not `sign-order`).

#### Workflow

Describe when this hook occurs in a workflow. Hook creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion among implementers.

### Context

Describe the set of contextual data used by this hook. Only data logically and necessarily associated with the purpose of this hook should be represented in context.

All fields defined by the hook's context MUST be defined in a table where each field is described by the following attributes:

- Field: The name of the field in the context JSON object. Hook authors SHOULD name their context fields to be consistent with other existing hooks when referring to the same context field.
- Optionality: A string value of either `REQUIRED` or `OPTIONAL`
- Prefetch Token: A string value of either `Yes` or `No`, indicating whether this field can be tokenized in a prefetch template.
- Type: The type of the field in the context JSON object, expressed as the JSON type, or the name of a FHIR Resource type. Valid types are *boolean*, *string*, *number*, *object*, *array*, or the name of a FHIR resource type. When a field can be of multiple types, type names MUST be separated by a *pipe* (`|`)
- Description: A functional description of the context value. If this value can change according to the FHIR version in use, the description SHOULD describe the value for each supported FHIR version.

The table below illustrates a sample hook context table:

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`someField` | REQUIRED | Yes | *string* | A clear description of the value of this field.
`anotherField` | OPTIONAL | No | *number* | A clear description of the value of this field.
`someObject` | REQUIRED | No | *object* | A clear description of the value of this field.
`moreObjects` | OPTIONAL | No | *array* | A clear description of the items in this array.
`allFHIR` | OPTIONAL | No | *object* | A FHIR Bundle of the following FHIR resources using a specific version of FHIR.
{:.grid}

#### FHIR resources in context

For context fields that may contain multiple FHIR resources, the field SHOULD be defined as a FHIR Bundle, rather than as an array of FHIR resources. For example, multiple FHIR resources are necessary to describe all of the orders under review in the `order-sign` hook's `draftOrders` field. Hook definitions SHOULD prefer the use of FHIR Bundles over other bespoke data structures.

Often, context is populated with in-progress or in-memory data that may not yet be available from the FHIR server. For example, imagine a hook, `order-select` that is invoked when a user selects a medication during an order workflow. The context data for this hook would contain draft FHIR resources representing the medications that have been selected for ordering. In this case, the CDS Client should only provide these draft resources and not the full set of orders available from its FHIR server. The CDS service MAY pre-fetch or query for FHIR resources with other statuses.

All FHIR resources in context MUST be based on the same FHIR version.

#### Examples

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

### Hook Maturity Model
The intent of the CDS Hooks Maturity Model is to attain broad community engagement and consensus, before a hook is labeled as mature, that the hook is necessary, implementable, and worthwhile to the CDS Services and CDS Clients that would reasonably be expected to use it. Implementer feedback should drive the maturity of new hooks. Diverse participation in open developer forums and events, such as HL7 FHIR Connectathons, is necessary to achieve significant implementer feedback. The below criteria will be evaluated with these goals in mind.

    Hook maturity | 3 - Considered

The Hook maturity levels use the term CDS Client to generically refer to the clinical workflow system in which a CDS Services returned cards are displayed.

Maturity Level | Maturity title | Requirements
--- | --- | ---
0 | Draft | Hook is defined according to the [hook definition format](#hook-definition-format).
1 | Submitted  | _The above, and …_ Hook definition is written up as a [github pull request](https://github.com/cds-hooks/docs/tree/master/docs/hooks) using the [Hook template](https://github.com/cds-hooks/docs/wiki/Proposed-Hooks) and community feedback is solicited on the [zulip CDS Hooks stream](https://chat.fhir.org/#narrow/stream/179159-cds-hooks).
2 | Tested | _The above, and …_ The hook has been tested and successfully supports interoperability among at least one CDS Client and two independent CDS Services using semi-realistic data and scenarios (e.g. at a FHIR Connectathon). The github pull request defining the hook is approved and published by the CDS Hooks Project Management Committee.
3 | Considered |  _The above, and …_ At least 3 distinct organizations recorded ten distinct implementer comments (including a github issue, tracker item, or comment on the hook definition page), including at least two CDS Clients and three independent CDS Services. The hook has been tested at two Connectathons.
4 | Documented | _The above, and …_ The author agrees that the artifact is sufficiently stable to require implementer consultation for subsequent non-backward compatible changes.  The hook is implemented in the standard CDS Hooks sandbox and multiple prototype projects. The Hook specification SHALL: <ul><ol>Identify a broad set of example contexts in which the hook may be used with a minimum of three, but as many as 8-10.</ol><ol>Clearly differentiate the hook from similar hooks or other standards to help an implementer determine if the hook is correct for their scenario.</ol><ol>Explicitly document example scenarios when the hook should not be used.</ol></ul>
5 | Mature | _The above, and ..._ The hook has been implemented in production in at least two CDS Clients and three independent CDS Services. An HL7 working group ballots the hook and the hook has passed HL7 STU ballot.
6 | Normative | _The above, and ..._ the responsible HL7 working group and the CDS working group agree the material is ready to lock down and the hook has passed HL7 normative ballot
{:.grid}

### Changes to a Hook

Each hook MUST include a Metadata table at the beginning of the hook with the specification version and hook version as described in the following sections.

#### Specification Version

Because hooks are such an integral part of the CDS Hooks specification, hook definitions are associated with specific versions of the specification. The hook definition MUST include the version (or versions) of the CDS Hooks specification that it is defined to work with.

    specificationVersion | 1.0

Because the specification itself follows semantic versioning, the version specified here is a minimum specification version. In other words, a hook defined to work against 1.0 should continue to work against the 1.1 version of CDS Hooks. However, a hook that specifies 1.1 would not be expected to work in a CDS Hooks 1.0 environment.

#### Hook Version

To enable tracking of changes to hook definitions, each hook MUST include a version indicator, expressed as a string.

    hookVersion | 1.0

To help ensure the stability of CDS Hooks implementations, once a hook has been defined (i.e. published with a particular name so that it is available for implementation), breaking changes MUST NOT be made. This means that fields can be added and restrictions relaxed, but fields cannot be changed, and restrictions cannot be tightened.

In particular, the semantics of a hook (i.e. the meaning of the hook from the perspective of the CDS Client) cannot be changed. CDS Clients that implement specific hooks are responsible for ensuring the hook is called from the appropriate point in the workflow.

Note that this means that the name of the hook carries major version semantics. That is not to say that the name must include the major version, that is left as a choice to authors of the specification. For example, following version 1.x, the major version MAY be included in the name as "-2", "-3", etc. Eg: patient-view-2, patient-view-3, etc. Clean hook names increase usability. Ideally, an active hook name accurately defines the meaning and workflow of the hook in actual words.

The following types of changes are possible for a hook definition:

Change | Version Impact
------ | ----
Clarifications and corrections to documentation that do not impact functionality | Patch
Change of prefetch token status of an existing context field | Major
Addition of a new, REQUIRED field to the context | Major
Addition of a new, OPTIONAL field to the context | Minor
Change of optionality of an existing context field | Major
Change of type or cardinality of an existing context field | Major
Removal of an existing context field | Major
Change of semantics of an existing context field | Major
Change of semantics of the hook | Major

When a major change is made, the hook definition MUST be published under a new name. When a minor or patch change is made, the hook version MUST be updated. Hook definers MUST use [semantic versioning](https://semver.org/) to communicate the impact of changes in an industry standard way.

> Note that the intent of this table is to outline possible breaking changes. The authors have attempted to enumerate these types of changes exhaustively, but as new types of breaking changes are identified, this list will be updated.

#### Hook Maturity
As each hook progresses through a process of being defined, tested, implemented, used in production environments, and balloted, the hook's formal maturity level increases. Each hook has its own maturity level, which MUST be defined in the hook's definition and correspond to the [Hook Maturity Model](#hook-maturity-model).

    hookMaturity | 0 - Draft

#### Change Log

Changes made to a hook's definition MUST be documented in a change log to ensure hook consumers can track what has been changed over the life of a hook. The change log MUST contain the following elements:

- Version: The version of the change
- Description: A description of the change and its impact

For example:

Version | Description
---- | ----
1.1 | Added new context variable
1.0.1 | Clarified context variable usage
1.0 | Initial Release
