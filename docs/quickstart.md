# Quick Start
This quick start tutorial defines each of the actors and provide details for implementing the `patient-view` hook. 

A CDS Hooks scenario typically includes two main actors: EHR Service, and a CDS Service. Below is an example interaction for the patient-view hook.

![Patient View Hooks Overview](images/patient-view-hook-launch_spec.png)

## Building a CDS Service
A CDS service is an external service that responds to EHR requests through cards. There are several steps to setting up a CDS service: 

1. Create an endpoint for discovery
1. Develop a service
1. Test service with a [sandbox](http://sandbox.cds-hooks.org/)
1. Create a SMART app (or [borrowed](https://apps.smarthealthit.org/apps/pricing/open-source))
1. Test service + SMART app with an EHR

This tutorial recommends implementing the [security](specification/#security) after succesful open access testing.

### Endpoint for discovery
The CDS service must provide a stable endpoint for the EHR to discover the available services. A system must expose their services at `{baseUrl}/cds-services`. A service endpoint that supports the `patient-view` hook may return:

```json
{
  "services": [
    {
      "hook": "patient-view",
      "name": "Static CDS Service Example",
      "description": "An example of a CDS service that returns a card with SMART app recommendations.",
      "id": "static-patient-view",
      "prefetch": {
        "patientToGreet": "Patient/{{Patient.id}}"
      }
    }
  ]
}
```

The attributes available to describe a CDS services is documented in the [CDS Hooks specification](specification/#discovery).

<!-- After you have created your open end point, make sure to publish in the [participant matrix](https://github.com/argonautproject/cds-hooks/wiki/Participants) -->
 
### Develop a service
With a stable open end point available it's time to complete development of a service. A CDS service could provide **information**, a **suggestion**, or a **SMART app** link. The focus of the Argonaut CDS Hooks effort is a `patient-view` hook launching a SMART app so this guide will focus on the SMART app link.

A CDS `patient-view` hook could return the following card:

```json
{
  "cards": [
    {
      "summary": "SMART App Success Card",
      "indicator": "success",
      "detail": "This is an example SMART App success card.",
      "source": {
        "label": "Static CDS Service Example",
        "url": "https://example.com"
      },
      "links": [
        {
          "label": "SMART Example App",
          "url": "https://smart.example.com/launch",
          "type": "smart"
        }
      ]
    }
  ]
 }
```


### Create a SMART App
You may already have created a SMART app prior to this step, but just in case this is a reminder. The SMART app is launched from the link returned in your service. If you want to borrow a SMART app, check out the [app gallery](https://apps.smarthealthit.org/apps/pricing/open-source).

### Test service with a sandbox
The CDS Hooks initiative provides a publicly available [sandbox](http://sandbox.cds-hooks.org/) to test your service. 

Select the configure hooks:<br>
![Demo Configuration](images/demo-configure-hooks.png)

Delete the existing hooks, and then do a quick add with a reference to your CDS service:<br>
![Patient View Hooks Launch from Sandbox](images/demo-quick-add.png)

After testing with the sandbox, you are ready to connect with an EHR service.

## Building an EHR Service
Build out following sections:

1. Calls discovery endpoint 
1. Invoke service on patient-view 
1. Support for FHIR resources on request (context or pre-fetch)
1. Exposed non-secured FHIR server
1. Render card
1. Launch SMART app 
1. Tested with external CDS service

This tutorial recommends implementing the [security](specification/#security) after succesful open access testing.

### Calls discovery endpoint 
The CDS discovery endpoint provides the list of services a CDS provider supports, and the hooks a service should be invoked on. An EHR may configure their system to support a set of hooks at a certain location in their users work flow, or build a dynamic capability to interact with a CDS Service provider within a work flow. For the best end-user experience, this guide recommends a business analyst configure which hooks an EHR will support. 

Below is an example work flow where a business analyst accesses this list of available services by calling 

`GET https://example.com/cds-services` 

and then configures them in the system. 

![business analyst configuration](images/analyst-configuration-spec.png)

This image captures a business analyst reviewing services from one CDS provider. A business analyst may review services from multiple providers and configure appropriate services per user profiles.

### Invoke service on patient-view hook
The patient-view hook is invoked when a patient chart is opened. It's one of the most basic since the logic doesn't have any prior workflow dependencies. The service called on the patient-view hook could be dependent on patient characteristics, for example: sex, problems in problems list, active medications, etc. The current version of the CDS Hooks specification allows the EHR to decide which characteristics to consider. 

### Support for FHIR resources on request or prefetch
Often a CDS service will require additional information from the EHR to perform the decision support logic, or determine the appropriate SMART app to return. Prefetch provides the EHR the capability to pass a resource when invoking a service. For example, with a patient resource included a service could do a geography search for potential environmental risk factors. Below is an example request invoked on patient-view with a patient included: 

```json
{
   "hookInstance" : "23f1a303-991f-4118-86c5-11d99a39222e",
   "fhirServer" : "http://hooks.smarthealthit.org:9080",
   "hook" : "patient-view",
   "redirect" : "http://hooks2.smarthealthit.org/service-done.html",
   "user" : "Practitioner/example",
   "context" : [],
   "patient" : "1288992",
   "prefetch" : {
      "patientToGreet" : {
         "response" : {
            "status" : "200 OK"
         },
         "resource" : {
            "resourceType" : "Patient",
            "gender" : "male",
            "birthDate" : "1925-12-23",
            "id" : "1288992",
            "active" : true
         }
      }
   }
}
```


In some cases, additional information beyond what is included in the prefetch maybe required. The CDS service can request additional information using the FHIR REST APIs:

`GET [base]/AllergyIntolerance?patient=[id]`

It is recommended FHIR servers implement, and CDS Services follow, locale specific implementaiton guides. In the US, the recommended implementation guides to follow are the [Argonaut Data Query Guide (DSTU2)](http://www.fhir.org/guides/argonaut/r2/) or [HL7 US Core (STU3)](http://hl7.org/fhir/us/core/index.html). Each profile page within these implementation guides includes queries FHIR servers are required to support. 

### Exposed non-secured FHIR server
A non secured FHIR server is important to support testing with a CDS service. When the EHR moves a hook so to production the system to is expected to follow the guidelines in  the [security](specification/#security) requirements.

### Render card
The CDS service will provide a response in the form a of a 'card'. Your EHR needs to be able to display the card.

Example card JSON: 

```json
{
      "summary": "Bilirubin: Based on the age of this patient consider overlaying bilirubin [Mass/volume] results over a time-based risk chart",
      "indicator": "info",
      "detail": "The focus of this app is to reduce the incidence of severe hyperbilirubinemia and bilirubin encephalopathy while minimizing the risks of unintended harm such as maternal anxiety, decreased breastfeeding, and unnecessary costs or treatment.",
      "source": {
        "name": "Intermountain",
        "url": null
      },
      "links": [
        {
          "label": "Bilirubin SMART app",
          "url": "https://example.com/launch",
          "type": "smart"
       }
      ]
    }
```

Example card rendered: ![Card with SMART App link](images/Bilirubin_SMART_App_Card.png)


### Launch SMART app 

For some CDS services the end step will just display the card. For the patient-view hook discussed here, we are focused on launching a SMART app. The CDS Hooks guide places no additional constraints for launching a SMART app beyond those from [SMART on FHIR](http://docs.smarthealthit.org/authorization/). 

## Test with an external CDS service

No development is complete without testing with a CDS service provider. Find a member in the [community](community) and test away. 

