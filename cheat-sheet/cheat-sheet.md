# CDS Hooks 1.0 - [cds-hooks.org](https://cds-hooks.org)

# Overview

![alt text](https://raw.githubusercontent.com/cds-hooks/docs/master/docs/images/overview.png "Overview Diagram")

# Discovery

`GET {baseUrl}/cds-services`

<pre>
{
  <b>"services"</b>: [
    {
      <b>"hook"</b>: "hook-noun-verb",
      "title": "Human-friendly name",
      <b>"description"</b>: "Service description",
      <b>"id"</b>: "{id} portion of {baseUrl}/cds-services/{id}",
      "prefetch": {
        "typeOfData": "Resource/{{context.id}}"
      }
    }
  ]
}
</pre>

# CDS Service Request

`POST {baseUrl}/cds-services/{id}`

<pre>
{
  <b>"hook"</b>: "hook-noun-verb",
  <b>"hookInstance"</b>: "d1577c69-dfbe-44ad-ba6d-3e05e953b2ea",
  "fhirServer": "https://fhir.client.com/version",
  "fhirAuthorization": {
    "access_token": "opaque-token",
    "token_type": "Bearer",
    "expires_in": 300,
    "scope": "patient/Patient.read patient/Observation.read",
    "subject": "cds-service4"
  },
  <b>"context"</b>: {
    "userId": "Practitioner/example",
    "patientId": "123",
    "encounterId": "456"
  },
  "prefetch": {
    "patientToGreet" : {
      "resourceType" : "Patient",
      "gender" : "male",
      "birthDate" : "1925-12-23",
      "id" : "1288992",
      "active" : true
    }
  }
}
</pre>

# CDS Service Response

`200 OK`

<pre>
{
  <b>"cards"</b>: [
    {
      <b>"summary"</b>: "&lt;140 char Summary Message",
      "detail": "(optional) GitHub Markdown details",
      <b>"indicator"</b>: "info",
      <b>"source"</b>: {
        <b>"label"</b>: "Human-readable source label",
        "url": "https://example.com",
        "icon": "https://example.com/img/icon-100px.png"
      },
      "suggestions": [
        {
          <b>"label"</b>: "Human-readable suggestion label",
          "uuid": "e1187895-ad57-4ff7-a1f1-ccf954b2fe46",
          "actions": [
            {
              <b>"type"</b>: "create",
              <b>"description"</b>: "Create a prescription for Acetaminophen 250 MG",
              "resource": {
                "resourceType": "MedicationRequest",
                "id": "medrx001",
                "...": "&lt;snipped for brevity&gt;"
              }
            }
          ]
        }
      ],
      "links": [
        {
          <b>"label"</b>: "SMART Example App",
          <b>"url"</b>: "https://smart.example.com/launch",
          <b>"type"</b>: "smart",
          "appContext": "{\"session\":3456356,\"settings\":{\"module\":4235}}"
        }
      ]
    }
  ]
}
</pre>

# Sample Hook: patient-view

<pre>
"context": {
  <b>"userId"</b> : "Practitioner/123",
  <b>"patientId"</b> : "1288992",
  "encounterId" : "456"
}
</pre>

# CDS Client JWT Format

`Header`

<pre>
{
  <b>"alg"</b>: "ES384",
  <b>"typ"</b>: "JWT",
  <b>"kid"</b>: "example-kid",
  "jku": "https://fhir-ehr.example.com/jwk_uri"
}
</pre>

`Payload`
<pre>
{
  <b>"iss"</b>: "https://fhir-ehr.example.com/",
  <b>"aud"</b>: "https://cds.example.org/cds-services/some-service",
  <b>"exp"</b>: 1422568860,
  <b>"iat"</b>: 1311280970,
  <b>"jti"</b>: "ee22b021-e1b7-4611-ba5b-8eec6a33ac1e",
  "tenant": "2ddd6c3a-8e9a-44c6-a305-52111ad302a2"
}
</pre>

# Verifying CDS Client JWTs

* `iss` - ensure it's a whitelisted client
* `aud` - ensure it matches your service endpoint
* `exp` - ensure it’s not before the current date/time
* `tenant` - ensure it's a whitelisted tenant, if applicable
* JWT signature - ensure it matches the client's public key
* `jti` - ensure it hasn't been previously used

---

\* Required fields in **bold**