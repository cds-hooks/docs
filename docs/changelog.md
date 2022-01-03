# Change Log

## CDS Hooks 1.1
### Non-compatible (breaking) changes
The CDS Hooks project team strives to not brek backward compatibility between versions of the CDS Hooks specifications to aid both in interoperability 
and to prioritize existing implementations. In cases where this isn't possible, changes made in the CDS Hooks 1.1 specification that break backward compatibility are documented below. 

* If the CDS Clients provides a `fhirAuthorization` and access_token to a service, and the access_token is granted SMART "patient/"-level scopes, the `fhirAuthorization` object must now contain the FHIR id of the patient to which the access_token is restricted. See: [FHIR-28761](https://jira.hl7.org/browse/FHIR-28761), and [PR#601](https://github.com/cds-hooks/docs/pull/601)
