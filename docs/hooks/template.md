# <mark>`hook-name-expressed-as-noun-verb`</mark>

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0
| hookMaturity | [0 - Draft](../../specification/1.0/#hook-maturity-model)

## Workflow

<mark>Describe when this hook occurs in a workflow. Hook creators SHOULD include as much detail and clarity as possible to minimize any ambiguity or confusion amongst implementors.</mark>

## Context

<mark>Define context values that are available when this hook occurs, and indicate whether they must be provided, and whether they are available for parameterizing prefetch templates.</mark>

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
<mark>`exampleId`</mark> | REQUIRED | Yes | *string* | <mark>Describe the context value</mark>
<mark>`encounterId`</mark> | OPTIONAL | Yes | *string* | <mark>Describe the context value</mark>

### Examples

<mark>
```json
"context":{
  "patientId" : "1288992"
}
```

```json
"context":{
  "patientId" : "1288992",
  "encounterId" : "456"
}
```
</mark>

## Change Log

Version | Description
---- | ----
1.0 | Initial Release

