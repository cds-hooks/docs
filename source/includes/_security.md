# Security

<aside class="notice">
The CDS Hooks security model is undergoing a rigorous security assessment and as such, may be subject to change.
</aside>

CDS Hooks defines the agreed upon security model between an EHR and the CDS Service. Like SMART on FHIR, the security model of CDS Hooks leverages the same open and well supported standards like OAuth 2 and JSON web tokens. However, as CDS Hooks differs from SMART, the manner in which these standards are used is specific to CDS Hooks.

## Trusting CDS Services

As the EHR initiates every interaction with the CDS Service, it is responsible for establishing trust with the CDS Services it intends to call. This trust is established via a TLS connection to the CDS Service. Thus, all CDS Service endpoints must be deployed to a TLS protected URL (https). This includes both the Discovery and individual CDS Service endpoints.

EHRs should use accepted best practices for verifying the authenticity and trust of these TLS connections. For instance, [rfc5280](https://tools.ietf.org/html/rfc5280) and [rfc6125](https://tools.ietf.org/html/rfc6125). Additionally, it is assumed that EHRs configure the CDS Services they connect to via some offline process according to the business rules and practices of both the EHR and CDS Service organizations.

## Trusting EHRs

Since the CDS Service is invoked by the EHR, the CDS Service does not have the same mechanism as EHRs to establish trust of the EHR invoking it. Signed [JSON web tokens (JWT)](https://jwt.io/) are produced by the EHR and provided to the CDS Service, allowing the CDS Service to establish trust of the calling EHR.

Each time the EHR makes a request to the CDS Service, it must send an `Authorization` header where the value is `Bearer <token>`, replacing `<token>` with the actual JWT. Note that this is for every single CDS Service call, whether that be Discovery calls, CDS Service invocations, etc.

> Example JSON web token payload

```json
{
  "iss": "https://fhir-ehr.example.com/",
  "aud": "https://cds.example.org/cds-services/some-service",
  "exp": 1422568860,
  "iat": 1311280970,
  "jti": "ee22b021-e1b7-4611-ba5b-8eec6a33ac1e"
}
```

> Using the above JWT payload, the complete JWT as passed in the Authorization HTTP header would be:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2ZoaXItZWhyLmV4YW1wbGUuY29tLyIsImF1ZCI6Imh0dHBzOi8vY2RzLmV4YW1wbGUub3JnL2Nkcy1zZXJ2aWNlcy9zb21lLXNlcnZpY2UiLCJleHAiOjE0MjI1Njg4NjAsImlhdCI6MTMxMTI4MDk3MCwianRpIjoiZWUyMmIwMjEtZTFiNy00NjExLWJhNWItOGVlYzZhMzNhYzFlIn0.Gwl3s301OMWpdEVAVj_T3JZV8bs7N5-V7QNNG7TQ33o
```

The JWT from the EHR is signed with the EHR's private key and contains the following fields:

Field | Value
----- | -----
iss | *string* The URL of the issuer of this JWT.
aud | *string or array of strings* The CDS Service endpoint that is being called by the EHR. (See more details below).
exp | *number* Expiration time integer for this authentication JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC).
iat | *number* The time at which this JWT was issued, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC).
jti | *string* A nonce string value that uniquely identifies this authentication JWT (used to protect against replay attacks)

Per [rfc7519](https://tools.ietf.org/html/rfc7519#section-4.1.3), the `aud` value is either a string or an array of strings. For CDS Hooks, this is the URL of the CDS Service endpoint being invoked. For example, consider a CDS Service available at a base URL of `https://cds.example.org`. When the EHR invokes the CDS Service discovery endpoint, the aud value is either `"https://cds.example.org/cds-services"` or `["https://cds.example.org/cds-services"]`. Similarly, when the EHR invokes a particular CDS Service (say, `some-service`), the aud value is either `"https://cds.example.org/cds-services/some-service"` or `["https://cds.example.org/cds-services/some-service"]`.

[https://jwt.io/](https://jwt.io/) is a great resource not only for learning about JSON web tokens, but also for parsing a JWT value into its distinct parts to see how it is constructed. Try taking the example JWT here and pasting it into the form at [https://jwt.io/](https://jwt.io/) to see how the token is constructed.

<aside class="notice">
At this time, CDS Hooks does not prescribe how the EHR shares its public key or the format of said key used in the JWT signature.
</aside>

### Mutual TLS

[Mutual TLS](https://en.wikipedia.org/wiki/Mutual_authentication) (mTLS) may be used alongside JSON web tokens to establish trust of the EHR by the CDS Service.

## FHIR Resource Access

The CDS Service is able to use the FHIR server of the EHR to obtain any additional data it needs in order to perform its decision support. This is similar to SMART on FHIR where the SMART app can obtain additional data via the provided FHIR server.

Like SMART on FHIR, CDS Hooks requires that access to the FHIR server be controlled by an Authorization server utilizing the OAuth 2 framework. Thus, the CDS Service is able to consume the given FHIR server via an access (bearer) token just like a SMART app. While CDS Hooks shares the underlying technical framework and standards as SMART on FHIR, there are very important differences between SMART and CDS Hooks.

### Obtaining an Access Token

In SMART on FHIR, the SMART app requests and ultimately obtains an access token from the Authorization server using the SMART launch workflow. This process utilizes the authorization code grant model as defined by the OAuth 2.0 Authorization Framework in [rfc6749](https://tools.ietf.org/html/rfc6749).

With CDS Hooks, the EHR provides the access token directly in the request to the CDS Service. Thus, the CDS Service does not need to request the token from the authorization server as a SMART app would. This is done purely for performance reasons as the authorization code grant model in OAuth 2 involves several HTTPS calls and redirects. In contrast to a SMART app, a CDS Service may be invoked many times during a workflow. Going through the authorization code grant model on every hook invocation would likely result in a poorly performing CDS Service due to the authorization overhead.

```json
{
  "fhirAuthorization" : {
    "access_token" : "some-opaque-fhir-access-token",
    "token_type" : "Bearer",
    "expires_in" : 300,
    "scope" : "patient/Patient.read patient/Observation.read"
  }
}
```

### Access Token

The access token is specified in the CDS Service request via the `fhirAuthorization` request parameter. This parameter is an object that contains both the access token as well as other related information.

Field | Description
----- | -----------
`access_token` |*string*. This is the OAuth 2 access token that provides access to the FHIR server.
`token_type`   |*string*. Fixed value: `Bearer`
`expires_in`   |*integer*. The lifetime in seconds of the access token.
`scope`        |*string*. The scopes the access token grants the CDS Service.

It is recommended that the `expires_in` value be very short lived as the access token must be treated as a transient value by the CDS Service.

It is recommended that the `scope` value contain just the scopes that the CDS Service needs for its logic and no more.

As the CDS Service is executing on behalf of a user, it is important that the data the CDS Service has access to is under the same restrictions/authorization as the current user. As such, the access token shall be scoped to:

- The CDS Service being invoked
- The current user

### Frequently Asked Questions

1. How is the user (clinician) prompted to authorize the CDS Service to obtain an access token on behalf of the user? If we're aligning with how security works for SMART apps, this is what happens today.

Not quite. There is actually no requirement that there be any user interaction to authorize a SMART app to obtain an access token. More generally, the OAuth 2 framework does not prescribe *how* authorization is determined. That is, authorization may be determined via some user interruptive decision, some pre-existing business rules, or even by random chance! The authorization server is free to determine how it grants access to the resources it protects.

With SMART on FHIR, we have seen real production behavior in which the authorization server:

- Grants access to practitioner facing SMART apps via some predefined business arrangement that was done out-of-band. The user (practitioner) never is asked to authorize the SMART app as their organization (hospital) has already made this decision for them.
- Grants access to patient facing SMART apps by asking the user explicitly for permission to both launch the SMART app as well as what specific scopes (data permissions) the SMART app may have.

2. The FHIR access token model places quite a bit of work on the EHRs. Why?

Yes, requiring the EHRs to obtain and share the access token with each CDS Service on each hook invocation isn't trivial work. However, the need to control the performance of the CDS Service invocations necessitates a different approach than SMART on FHIR. By putting the burden on the EHRs to obtain this access token, it is left to the EHR to manage this cost appropriately. Given the authorization server and EHR are controlled by the same organization, it is assumed the EHR is in a much better position to implement strategies to both obtain and manage access tokens in a performant manner in a model like CDS Hooks.

Unlike SMART apps, CDS Services should treat access tokens as transient tokens used during the course of a single evaluation of decision support. If the EHRs did not bear the responsibility of obtaining the access token on behalf of the CDS Service, each CDS Service would need to not only obtain the token themselves, but also determine a performant manner to optimize token (re)use when their service is invoked for the same user/patient.

## Cross-Origin Resource Sharing

[Cross-origin resource sharing (CORS)](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS) is web security mechanism that is built into browsers. In short, CORS allows servers to control how browsers access resources on the server, including the accessible HTTP response headers. CORS is only honored by web browsers and as such, is a client-side security mechanism.

For CDS Services, implementing CORS is required if your CDS Service is to be called from a web browser. As the [CDS Hooks Sandbox](http://sandbox.cds-hooks.org) is a browser application, you must implement CORS to test your CDS Service in the CDS Hooks Sandbox.

You should carefully consider if and how you support CORS in your CDS Service. A secure implementation guide for CORS is outside of the CDS Hooks specification, as it involves implementation decisions that are made based upon your organization's tolerance for risk and deployment environment.

An insecure, extremely permissive, non-production CORS configuration that allows you to test your CDS Service against our Sandbox returns the following HTTP headers:

Header | Value
------ | -----
Access-Control-Allow-Credentials | true
Access-Control-Allow-Headers | Authorization, Content-Type
Access-Control-Allow-Methods | GET, POST, OPTIONS
Access-Control-Allow-Origin | *
Access-Control-Expose-Headers | Origin, Accept, Content-Location, Location, X-Requested-With
