# Security

CDS Hooks defines the agreed upon security model between an EHR and the CDS Service. Like SMART on FHIR, the security model of CDS Hooks leverages the same open and well supported standards like OAuth 2 and JSON web tokens. However, as CDS Hooks differs from SMART, the manny in which these standards are used is specific to CDS Hooks.

## Trusting CDS Services

As the EHR initiates every interaction with the CDS Service, it is responsible for establishing trust with the CDS Services it intends to call. This trust is established via a TLS connection to the CDS Service. Thus, all CDS Service endpoints must be deployed to a TLS protected URL (https). This includes both the Discovery and individual CDS Service endpoints.

EHRs should use accepted best practices for verifying the authenticity and trust of these TLS connections. For instance, [rfc5280](https://tools.ietf.org/html/rfc5280) and [rfc6125](https://tools.ietf.org/html/rfc6125). Additionally, it is assumed that EHRs configure the CDS Services they connect to via some offline process according to the business rules and practices of both the EHR and CDS Service organizations.

## Trusting EHRs

Since the CDS Service is invoked by the EHR, the CDS Service does not have the same mechanism as EHRs to establish trust of the EHR invoking it. To establish trust of the EHR, [JSON web tokens](https://jwt.io/) are used.

Each time the EHR makes a request to the CDS Service, it should send an `Authorization` header where the value is `Bearer <token>`, replacing `<token>` with the actual JWT. Note that this is for every single CDS Service call, whether that be Discovery calls, CDS Service invocations, etc.

> Example JSON web token payload

```json
{
  "iss": "https://fhir-ehr.example.com/",
  "aud": "https://cds.example.org/cds-services",
  "exp": 1422568860,
  "jti": "2af5e8a5-b5ef-4fd0-8d93-c560dac40c98"
}
```

> Using the above JWT payload, the complete JWT as passed in the Authorization HTTP header would be:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2ZoaXItZWhyLmV4YW1wbGUuY29tLyIsImF1ZCI6Imh0dHBzOi8vY2RzLmV4YW1wbGUub3JnL2Nkcy1zZXJ2aWNlcyIsImV4cCI6MTQyMjU2ODg2MCwianRpIjoiMmFmNWU4YTUtYjVlZi00ZmQwLThkOTMtYzU2MGRhYzQwYzk4In0.ahR57rtcMFhvrHEEo9w13vVdLrhZs_gRY2NV6R2GAoU
```

The JWT from the EHR is signed with the EHR's private key and contains the following fields:

Field | Value
----- | -----
iss | The base URL of the EHR's FHIR server. This must be the same URL as the `fhirServer` field in a CDS Service request.
aud | The URL being invoked by the EHR.
exp | Expiration time integer for this authentication JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC). This time MUST be no more than five minutes in the future.
jti | A nonce string value that uniquely identifies this authentication JWT.

Note that the use of JWT in CDS Hooks resembles the [SMART on FHIR Backend Services](http://docs.smarthealthit.org/authorization/backend-services/) usage of JWT. However, there are differences due to the differing use cases and concerns between CDS Hooks and SMART Backend Services.

[https://jwt.io/](https://jwt.io/) is a great resource not only for learning about JSON web tokens, but also for parsing a JWT value into its distinct parts to see how it is constructed. Try taking the example JWT here and pasting it into the form at [https://jwt.io/](https://jwt.io/) to see how the token is constructed.

<aside class="notice">
TODO: Need to propose how the EHR public key is discovered. Preference would be a further extension in the EHR FHIR server Conformance resource.
</aside>

### Mutual TLS

[Mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication) (mTLS) can be used between an EHR and CDS Service and that would allow the CDS Service to establish trust of the EHR. However, if mTLS is used, this should be in addition to using JSON web tokens to establish trust of the EHR. As mTLS is not well supported across all platforms and technologies, it is not the standard means of establishing trust with the EHR.

## FHIR Resource Access

TODO

## Cross-Origin Resource Sharing

[Cross-origin resource sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) is web security mechanism that is built into browsers. In short, CORS allows servers to control how browsers access resources on the server, including the accessible HTTP response headers. CORS is only honored by web browsers and as such, is a client-side security mechanism.

For CDS Services, implementing CORS is required if your CDS Service is to be called from a web browser. As the [CDS Hooks Sandbox](http://sandbox.cds-hooks.org) is a browser application, you must implement CORS to test your CDS Service in the CDS Hooks Sandbox.

You should carefully consider how you support CORS, but a quick starting point for testing would be to ensure your CDS Service returns the following HTTP headers:

Header | Value
------ | -----
Access-Control-Allow-Credentials | true
Access-Control-Allow-Methods | GET, POST, OPTIONS
Access-Control-Allow-Origin | *
Access-Control-Expose-Headers | Origin, Accept, Content-Location, Location, X-Requested-With
