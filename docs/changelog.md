# Change Log

## CDS Hooks 1.1
### Non-compatible (breaking) changes
The CDS Hooks project team strives to not brek backward compatibility between versions of the CDS Hooks specifications to aid both in interoperability 
and to prioritize existing implementations. In cases where this isn't possible, changes made in the CDS Hooks 1.1 specification that break backward compatibility are documented below. 

* CDS Clients may now paginate search results in prefetch. Previously, CDS Clients were not permitted to return partial search results using the [typical FHIR pagination mechanism](https://www.hl7.org/fhir/http.html#paging). When using prefetch, CDS Services should expect to receive continuation links which enable access to the remainder of the search results over REST.
