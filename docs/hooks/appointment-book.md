# `appointment-book`

| Metadata | Value
| ---- | ----
| specificationVersion | 1.0
| hookVersion | 1.0
| hookMaturity | 1 - Submitted

## Workflow

This hook is invoked when the user is scheduling one or more future encounters/visits for the patient.  It may be invoked at the start and end of the booking process and/or any time between those two points.  It allows CDS Services to intervene in the decision of when future appointments should be scheduled, where they should be scheduled, what services should be booked, to identify actions that need to occur prior to scheduled appointments, etc.

## Context

The Patient whose appointment(s) are being booked, as well as the proposed Appointment records.

Field | Optionality | Prefetch Token | Type | Description
----- | -------- | ---- | ---- | ----
`userId` | REQUIRED | Yes | *string* | The id of the current user.<br />For this hook, the user could be of type [Practitioner](https://www.hl7.org/fhir/practitioner.html), [PractitionerRole](https://www.hl7.org/fhir/practitionerrole.html), [Patient](https://www.hl7.org/fhir/patient.html), or [RelatedPerson](https://www.hl7.org/fhir/relatedperson.html).<br />For example, `Practitioner/123`
`patientId` | REQUIRED | Yes | *string* | The FHIR `Patient.id` of Patient appointment(s) is/are for
`encounterId` | OPTIONAL | Yes | *string* | The FHIR `Encounter.id` of Encounter where booking was initiated
`appointments` | REQUIRED | No | *object* | DSTU2/STU3/R4 - FHIR Bundle of Appointments in 'proposed' state


### Examples (STU3)

```json
"context":{
  "userId" : "PractitionerRole/A2340113",
  "patientId" : "1288992",
  "appointments" : [
    {
      "resourceType": "Appointment",
      "id": "apt1",
      "status": "proposed",
      "serviceType": [
        {
          "coding": [
            {
              "code": "183",
              "display": "Sleep Medicine"
            }
          ]
        }
      ],
      "appointmentType": {
        "coding": [
          {
            "system": "http://hl7.org/fhir/v2/0276",
            "code": "FOLLOWUP",
            "display": "A follow up visit from a previous appointment"
          }
        ]
      },
      "reason": {
        "coding": {
          "system": "",
          "code": "1023001",
          "display": "Apnea"
        }
      },
      "description": "CPAP adjustments",
      "start": "2019-08-10T09:00:00-06:00",
      "end": "2019-08-10T09:10:00:00-06:00",
      "created": "2019-08-01",
      "participant": [
        {
          "actor": {
            "reference": "Patient/example",
            "display": "Peter James Chalmers"
          },
          "required": "required",
          "status": "tentative"
        },
        {
          "actor": {
            "reference": "Practitioner/example",
            "display": "Dr Adam Careful"
          },
          "required": "required",
          "status": "accepted"
        }
      ]
    },
    {
      "resourceType": "Appointment",
      "id": "apt1",
      "status": "proposed",
      "appointmentType": {
        "coding": [
          {
            "system": "http://hl7.org/fhir/v2/0276",
            "code": "CHECKUP",
            "display": "A routine check-up, such as an annual physical"
          }
        ]
      },
      "description": "Regular physical",
      "start": "2020-08-01T13:00:00-06:00",
      "end": "2020-08-01T13:30:00:00-06:00",
      "created": "2019-08-01",
      "participant": [
        {
          "actor": {
            "reference": "Patient/example",
            "display": "Peter James Chalmers"
          },
          "required": "required",
          "status": "tentative"
        },
        {
          "actor": {
            "reference": "Practitioner/example",
            "display": "Dr Adam Careful"
          },
          "required": "required",
          "status": "accepted"
        }
      ]
    }
  ]
}
```

```json 
"context":{
  "userId" : "PractitionerRole/A2340113",
  "patientId" : "1288992",
  "encounterId" : "456",
  "appointment" : [
    {
      "resourceType": "Appointment",
      "id": "example",
      "text": {
        "status": "generated",
        "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\">Brian MRI results discussion</div>"
      },
      "status": "proposed",
      "serviceCategory": {
        "coding": [
          {
            "system": "http://example.org/service-category",
            "code": "gp",
            "display": "General Practice"
          }
        ]
      },
      "serviceType": [
        {
          "coding": [
            {
              "code": "52",
              "display": "General Discussion"
            }
          ]
        }
      ],
      "specialty": [
        {
          "coding": [
            {
              "system": "http://example.org/specialty",
              "code": "gp",
              "display": "General Practice"
            }
          ]
        }
      ],
      "appointmentType": {
        "coding": [
          {
            "system": "http://example.org/appointment-type",
            "code": "follow",
            "display": "Followup"
          }
        ]
      },
      "indication": [
        {
          "reference": "Condition/example",
          "display": "Severe burn of left ear"
        }
      ],
      "priority": 5,
      "description": "Discussion on the results of your recent MRI",
      "start": "2013-12-10T09:00:00Z",
      "end": "2013-12-10T11:00:00Z",
      "created": "2013-10-10",
      "comment": "Further expand on the results of the MRI and determine the next actions that may be appropriate.",
      "incomingReferral": [
        {
          "reference": "ReferralRequest/example"
        }
      ],
      "participant": [
        {
          "actor": {
            "reference": "Patient/example",
            "display": "Peter James Chalmers"
          },
          "required": "required",
          "status": "tentative"
        },
        {
          "type": [
            {
              "coding": [
                {
                  "system": "http://hl7.org/fhir/v3/ParticipationType",
                  "code": "ATND"
                }
              ]
            }
          ],
          "actor": {
            "reference": "Practitioner/example",
            "display": "Dr Adam Careful"
          },
          "required": "required",
          "status": "accepted"
        },
        {
          "actor": {
            "reference": "Location/1",
            "display": "South Wing, second floor"
          },
          "required": "required",
          "status": "action-needed"
        }
      ]
    }
  ]
}
```

## Change Log

Version | Description
---- | ----
1.0 | Initial Release

