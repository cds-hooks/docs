## Extensions

The specification is not prescriptive about support for extensions. However, to support extensions, the specification reserves the name `extension` and will never define an element with that name, allowing implementations to use it to provide custom behavior and information. The value of an extension element MUST be a pre-coordinated JSON object. Extension structures SHOULD use a strategy for naming that ensures global uniqueness, such as reverse-domain-name notation, as in the examples below. The intention here is that anything that has broad ranging value across the community enough to be a standardized extension has broad ranging value enough to be a first class citizen rather than an extension in CDS Hooks.

> STU Note: We seek implementer feedback on whether the recommendation to use namespace-based unique naming in the extension specification should be made mandatory or that we consider adding a mandatory field to extensions that indicates the source/type of the extension (as is done with FHIR).

For example, an extension on a request could look like this:

```json
{
  "hookInstance": "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
  "fhirServer": "http://fhir.example.org:9080",
  "hook": "patient-view",
  "context": {
    "userId": "Practitioner/example"
  },
  "extension": {
    "com.example.timestamp": "2017-11-27T22:13:25Z",
    "com.cds-hooks.sandbox.myextension-practitionerspecialty": "gastroenterology"
  }
}
```

As another example, an extension defined on the discovery response could look like this:

```json
{
  "services": [
    {
      "title": "Example CDS Service Discovery",
      "hook": "patient-view",
      "id": "patientview",
      "prefetch": {
        "patient": "Patient/{{context.patientId}}"
      },
      "description": "clinical decision support for patient view",
      "extension": {
        "com.example.clientConformance": "http://hooks.example.org/fhir/102/Conformance/patientview"
      }
    }
  ]
}
```
[OAuth 2.0]: https://oauth.net/2/



## Data Types

CDS Hooks leverages json data types throughout.  This section defines data structures re-used across the specification.

### Coding

The **Coding** data type captures the concept of a code. A code is understood only when the given code, code-system, and a optionally a human readable display are available. This coding type is a standalone data type in CDS Hooks modeled after a trimmed down version of the [FHIR Coding data type](http://hl7.org/fhir/datatypes.html#Coding).

Field | Optionality | Type | Description
----- | ----- | ----- | --------
`code` | REQUIRED | *string* | The code for what is being represented
`system` | REQUIRED | *string* | The codesystem for this `code`.
`display` | CONDITIONAL | *string* | A short, human-readable label to display. REQUIRED for [Override Reasons](services.html#overridereason) provided by the CDS Service, OPTIONAL for [Topic](services.html#source).
{:.grid}
