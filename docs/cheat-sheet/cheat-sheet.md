# Overview

![alt text](https://raw.githubusercontent.com/cds-hooks/docs/master/docs/images/overview.png "Overview Diagram")

# Links

* Spec: https://cds-hooks.hl7.org/1.0/
* Sandbox: http://sandbox.cds-hooks.org/
* Quick Start: https://cds-hooks.org/quickstart/

# CDS Service Discovery

`GET {baseUrl}/cds-services`

## Response Body

services - An array of **CDS Service**s

### CDS Service: ###

Field | Optionality | Summary
------|-------------|------------
`hook` | REQUIRED | hook this service should be invoked on
`title` | RECOMMENDED | human-friendly name of this service
`description` | REQUIRED | description of this service
`id` | REQUIRED | {id} portion of service URL: {baseUrl}/cds-services/{id} 
`prefetch` | OPTIONAL | Object containing key/value pairs of FHIR queries that this service is requesting the CDS Client to include on service calls

## Example

<pre>
{
  "services": [
    {
      "hook": "hook-noun-verb",
      "title": "CDS Service Example",
      "description": "An example of a CDS Service that returns a card",
      "id": "patient-greeter",
      "prefetch": {
        "patientToGreet": "Patient/{{context.patientId}}"
      }
    }
  ]
}
</pre>

# CDS Service Request

`POST {baseUrl}/cds-services/{id}`

## Request Body ##

Field | Optionality | Summary
------|-------------|------------
`hook` | REQUIRED | hook that triggered this CDS Service call
`hookInstance` | REQUIRED | UUID for this hook call
`fhirServer` | OPTIONAL | base URL for CDS Client’s FHIR server
`fhirAuthorization` | OPTIONAL | structure with **FHIR Authorization** information for the above url
`context` | REQUIRED | hook-specific contextual data
`prefetch` | OPTIONAL | FHIR data prefetched by the CDS Client

### FHIR Authorization ###

Field | Optionality | Summary
------|-------------|------------
`access_token` | REQUIRED | OAuth 2.0 access token
`token_type` | REQUIRED | fixed value: `Bearer`
`expires_in` | REQUIRED | lifetime in seconds of the access token
`scope` | REQUIRED | scopes the access token grants to the CDS Service
`subject` | REQUIRED | OAuth 2.0 client id of the CDS Service’s auth server registration 

## Example ## 

<pre>
{
   "hook": "hook-noun-verb",
   "hookInstance": "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
   "fhirServer": "https://fhir.client.com/version",
   "fhirAuthorization": {
      "access_token": "opaque-token",
      "...": "&ltsnipped for brevity&gt"
   },
   "context": {
      "userId": "Practitioner/example",
      "...": "&ltsnipped for brevity&gt"
   },
   "prefetch": {
      "patientToGreet": {
         "resourceType": "Patient",
         "...": "&ltsnipped for brevity&gt"
      }
   }
}
</pre>

# CDS Service Response Body

Field | Optionality | Summary
------|-------------|------------
`cards` | REQUIRED | an array of **Card**s with a combination of information, suggested actions, and links

## Card

Field | Optionality | Summary
------|-------------|------------
`summary` | REQUIRED | <140-character summary sentence for display to the user inside of this card
`detail` | OPTIONAL | optional detailed information to display (GitHub Flavored Markdown)
`indicator` | REQUIRED | urgency/importance of what this card conveys (`info/warning/critical`)
`source` | REQUIRED | grouping structure for the **Source** of information displayed on this card
`suggestions` | OPTIONAL |  array of **Suggestion**s for changes in the context of the current activity
`selectionBehavior` | OPTIONAL | intended behavior of the suggestions.  If suggestions present, value must be `at-most-one`
`links` | OPTIONAL | array of **Link**s to suggest an app or other additional information

## Source

Field | Optionality | Summary
------|-------------|------------
`label` | REQUIRED | short, human-readable label to display source of the card’s information
`url` | OPTIONAL | optional absolute URL to load to learn more about the organization or data set
`icon` | OPTIONAL | absolute url for an icon for the source of this card (100x100 pixel PNG without any transparent regions)

## Suggestion

Field | Optionality | Summary
------|-------------|------------
`label` | REQUIRED | human-readable label to display for this suggestion
`uuid` | OPTIONAL | unique identifier for auditing and logging suggestions
`actions` | OPTIONAL | array of suggested Actions (logically AND’d together)

## Action

Field | Optionality | Summary
------|-------------|------------
`type` | REQUIRED | type of action being performed (`create/update/delete`)
`description` | REQUIRED | human-readable description of the suggested action
`resource` | OPTIONAL | FHIR resource to create/update or id of resource to delete  

## Link

Field | Optionality | Summary
------|-------------|------------
`label` | REQUIRED | human-readable label to display
`url` | REQUIRED | URL to GET when link is clicked
`type` | REQUIRED | type of the given URL (`absolute/smart`) 
`appContext` | OPTIONAL | additional context to share with a linked SMART app

## Example

<pre>
{
   "cards": [
      {
         "summary": "&lt140 char Summary Message",
         "detail": "optional GitHub Markdown details",
         "indicator": "info",
         "source": {
            "label": "Human-readable source label",
            "url": "https://example.com",
            "icon": "https://example.com/img/icon-100px.png"
         },
         "suggestions": [
            {
               "label": "Human-readable suggestion label",
               "uuid": "e1187895-ad57-4ff7-a1f1-ccf954b2fe46",
               "actions": [
                  {
                     "type": "create",
                     "description": "Create a prescription for Acetaminophen 250 MG",
                     "resource": {
                        "resourceType": "MedicationRequest",
                        "...": "&ltsnipped for brevity&gt"
                     }
                  }
               ]
            }
         ],
         "links": [
            {
               "label": "SMART Example App",
               "...": "&ltsnipped for brevity&gt"
            }
         ]
      }
   ]
}
</pre>
