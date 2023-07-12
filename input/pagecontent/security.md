## Security and Safety

All data exchanged through the RESTful APIs MUST  be transmitted over channels secured using the Hypertext Transfer Protocol (HTTP) over Transport Layer Security (TLS), also known as HTTPS and defined in [RFC2818](https://tools.ietf.org/html/rfc2818).

Security and safety risks associated with the CDS Hooks API include:

1.	The risk that confidential information and privileged authorizations transmitted between a CDS Client and a CDS Service could be surreptitiously intercepted by an attacker;
2.	The risk that an attacker masquerading as a legitimate CDS Service could receive confidential information or privileged authorizations from a CDS Client, or could provide to a CDS Client decision support recommendations that could be harmful to a patient;
3.	The risk that an attacker masquerading as a legitimate service-subscribing CDS Client (i.e., man-in-the-middle) could intercept and possibly alter data exchanged between the two parties.
4.	The risk that a CDS Service could embed dangerous suggestions or links to dangerous apps in Cards returned to a CDS Client.
5.	The risk that a CDS Hooks browser-based deployment could be victimized by a Cross-Origin Resource Sharing (CORS) attack.
6.	The risk that a CDS Service could return a decision based on outdated patient data, resulting in a safety risk to the patient.

CDS Hooks defines a security model that addresses these risks by assuring that the identities of both the CDS Service and the CDS Client are authenticated to each other; by protecting confidential information and privileged authorizations shared between a CDS Client and a CDS Service; by recommending means of assuring data freshness; and by incorporating business mechanisms through which trust is established and maintained between a CDS Client and a CDS Service. As with any access to protected patient information, systems should ensure that they have appropriate authorization and audit mechanisms in place to support transparency of use of the data. For more information, refer to [Security Best Practices](https://cds-hooks.org/best-practices/#security).

### Trusting CDS Services

Prior to enabling CDS Clients to request decision support from any CDS Service, the CDS Client vendor and/or provider organization is expected to perform due diligence on the CDS Service provider.  Each CDS Client vendor/provider is individually responsible for determining the suitability, safety and integrity of the CDS Services it uses, based on the organization's own risk-management strategy.  Each CDS Client vendor/provider SHOULD maintain an "allow list" (and/or "deny list") of the CDS Services it has vetted, and the Card links that have been deemed safe to display from within the CDS Client context. Each provider organization is expected to work with its CDS Client vendor to choose what CDS Services to allow and to negotiate the conditions under which the CDS Services MAY be called.

Once a CDS Service provider is selected, the CDS Client vendor/provider negotiates the terms under which service will be provided.  This negotiation includes agreement on patient data elements that will be prefetched and provided to the CDS Service, the CDS Services used and the hooks that will trigger them, data elements that will be made available through an access token passed by the CDS Client, and steps the CDS Service MUST take to protect patient data and access tokens.  The CDS Service can be registered with the CDS Client's authorization server, in part to define the FHIR resources that the CDS Service has authorization to access. These business arrangements are documented in the service agreement.

Every interaction between a CDS Client and a CDS Service is initiated by the CDS Client sending a service request to a CDS Service endpoint protected using the [Transport Layer Security protocol](https://tools.ietf.org/html/rfc5246). Through the TLS protocol the identity of the CDS Service is authenticated, and an encrypted transmission channel is established between the CDS Client and the CDS Service. Both the Discovery endpoint and individual CDS Service endpoints are TLS secured.

The CDS Client's FHIR server, using information provided by the authorization server, is responsible for enforcing restrictions on the information available to the CDS Service. Regardless of whether FHIR resources are prefetched or retrieved from the FHIR server, the CDS Client SHALL deny access to a requested resource if it is outside the user's authorized scope. If a CDS Client is satisfying prefetch requests from a CDS Service or sends a non-null `fhirAuthorization` object to a CDS Service so that it can call the FHIR server, the CDS Service MUST be pre-registered with the authorization server protecting access to the FHIR server.  Pre-registration includes registering a client identifier, and agreeing upon the scope of FHIR access that is minimally necessary to provide the clinical decision support required. This specification does not address how the CDS Client, authorization server, and CDS Service perform this pre-registration.

### Trusting CDS Clients

The service agreement negotiated between the CDS Client vendor/provider and the CDS Service provider will include obligations the CDS Client vendor/provider commits to the CDS Service provider. Some agreements MAY include the use of mutual TLS, in which both ends of the channel are authenticated.

However, mutual TLS is impractical for many organizations. In the absence of mutual TLS, only the CDS Service endpoint will be authenticated because the CDS Client initiates the TLS channel set-up.  To enable the CDS Service to authenticate the identity of the CDS Client, CDS Hooks uses digitally signed [JSON web tokens (JWT)](https://jwt.io/) ([rfc7519](https://tools.ietf.org/html/rfc7519)). CDS Services SHOULD require authentication if invoking the service poses any risk of exposing sensitive data to the caller.


Each time a CDS Client transmits a request to a CDS Service which requires authentication, the request MUST include an `Authorization` header presenting the JWT as a “Bearer” token:
```
Authorization:  Bearer {{JWT}}
```
Note that this is for every single CDS Service call, whether that be a Discovery call, a single CDS Service invocation, or multiple exchanges relating to a single service. Also note that mutual TLS MAY be used alongside JSON web tokens to establish trust of the CDS Client by the CDS Service.

The CDS Client MUST use its private key to digitally sign the JWT, using the [JSON Web Signatures (rfc7515)](https://tools.ietf.org/html/rfc7515) standard.

The JWT header contains the following fields (see [rfc7515 section 4.1](https://tools.ietf.org/html/rfc7515#section-4.1) for further information on these standard headers):

Field | Optionality | Type | Value
----- | ----- | ----- | --------
alg | REQUIRED | *string* | The cryptographic algorithm used to sign this JWT.
kid | REQUIRED | *string* | The identifier of the key-pair used to sign this JWT. This identifier MUST be unique within the CDS Client's JWK Set.
typ | REQUIRED | *string* | Fixed value: `JWT`
jku | OPTIONAL | *url*    | The URL to the JWK Set containing the public key(s).
{:.grid}

The JWT payload contains the following fields:

Field | Optionality | Type | Value
----- | ----- | ----- | --------
iss | REQUIRED | *string* | The URI of the issuer of this JWT.  Note that the JWT MAY be self-issued by the CDS Client, or MAY be issued by a third-party identity provider.
aud | REQUIRED | *string* or *array of string* | The CDS Service endpoint that is being called by the CDS Client. (See more details below).
exp | REQUIRED | *number* | Expiration time integer for this authentication JWT, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC).
iat | REQUIRED | *number* | The time at which this JWT was issued, expressed in seconds since the "Epoch" (1970-01-01T00:00:00Z UTC).
jti | REQUIRED | *string* | A nonce string value that uniquely identifies this authentication JWT (used to protect against replay attacks).
tenant | OPTIONAL | *string* | An opaque string identifying the healthcare organization that is invoking the CDS Hooks request.
{:.grid}

CDS Services SHOULD limit the CDS Clients they trust by maintaining an allowlist of `iss` and `jku` urls.

Per [rfc7519](https://tools.ietf.org/html/rfc7519#section-4.1.3), the `aud` value is either a string or an array of strings. For CDS Hooks, this value MUST be the URL of the CDS Service endpoint being invoked. For example, consider a CDS Service available at a base URL of `https://cds.example.org`. When the CDS Client invokes the CDS Service discovery endpoint, the aud value is either `"https://cds.example.org/cds-services"` or `["https://cds.example.org/cds-services"]`. Similarly, when the CDS Client invokes a particular CDS Service (say, `some-service`), the aud value is either `"https://cds.example.org/cds-services/some-service"` or `["https://cds.example.org/cds-services/some-service"]`.

The CDS Client MUST make its public key, expressed as a JSON Web Key (JWK), available in a JWK Set, as defined by [rfc7517](https://tools.ietf.org/html/rfc7517). The `kid` value from the JWT header allows a CDS Service to identify the correct JWK in the JWK Set that can be used to verify the signature.

The CDS Client MAY make its JWK Set available via a URL identified by the `jku` header field, as defined by [rfc7515 4.1.2](https://tools.ietf.org/html/rfc7515#section-4.1.2). If the `jku` header field is ommitted, the CDS Client and CDS Service SHALL communicate the JWK Set out-of-band.

#### JWT Signing Algorithm

The cryptographic signing algorithm of JWT is indicated in the `alg` header field. [JSON Web Algorithms (rfc7518)](https://tools.ietf.org/html/rfc7518) defines several cryptographic algorithms for use in signing JWTs and should be referenced by CDS Hooks implementers.

JWTs SHALL NOT be signed using the `none` algorithm, referred to in rfc7518 as unsecured JSON Web Signatures, as the lack of a cryptographic signature does not provide any integrity protection. Such JWTs could not be used by a CDS Service to identity the CDS Client preventing an establishment of trust.

JWTs SHALL NOT be signed using any symmetric algorithm as these algorithms require the CDS Client and CDS Service to share a private key in order to verify the signature. For example, all HMAC based algorithms rely upon a shared private key and thus SHALL NOT be used to sign a JWT.

When choosing an algorithm to sign their JWTs, CDS Clients SHOULD consider not only the algorithms (and key sizes) that are recommended within the security industry, but also how well those algorithms are supported in the various programming languages and libraries that may be used by CDS Services.

At publication time of this specification, both ES384 and RS384 are RECOMMENDED for their regard within the larger security industry, strength, and support across popular programming languages and libraries. However, stronger and better algorithms are continually being introduced due to new threats, weaknesses, and increases in computing power. CDS Clients SHOULD continually re-evaluate their choice of an algorithm based upon these ever changing conditions.

CDS Services SHOULD consider the algorithms they understand and trust based upon their tolerance for risk.

#### Example

An example JSON web token header, payload, and JWK set:

```json
// JSON Web Token Header
{
  "alg": "ES384",
  "typ": "JWT",
  "kid": "example-kid",
  "jku": "https://fhir-ehr.example.com/jwk_uri"
}

// JSON Web Token Payload
{
  "iss": "https://fhir-ehr.example.com/",
  "aud": "https://cds.example.org/cds-services/some-service",
  "exp": 1422568860,
  "iat": 1311280970,
  "jti": "ee22b021-e1b7-4611-ba5b-8eec6a33ac1e",
  "tenant": "2ddd6c3a-8e9a-44c6-a305-52111ad302a2"
}

// JSON Web Key Set (public key)
// This public key is used by the CDS Service to verify the signature of the JWT
{
  "keys": [
    {
      "kty": "EC",
      "use": "sig",
      "crv": "P-384",
      "kid": "example-kid",
      "x": "46SDH7Znh821wblCBglA61sNE9ZrHYKKt3qRtRTmSXyOI_FIGBLWrWa0GPUkDCEk",
      "y": "XMcRuuoGW7CXjQdy-F5i3FeBE0x9hPLdeFdSoDd3ELmx404tLX0VRRcqzAsPhXcI",
      "alg": "ES384"
    }
  ]
}

// JSON Web Key (private key)
// This private key is used by the CDS Client to sign the JWT
{
  "kty": "EC",
  "d": "SeFXUXda8UomZ8GFUl7HH_Oi15rIbfMcsWj9ecIsDR8kLbqsEz2CGNgwy_IcILxy",
  "use": "sig",
  "crv": "P-384",
  "kid": "example-kid",
  "x": "46SDH7Znh821wblCBglA61sNE9ZrHYKKt3qRtRTmSXyOI_FIGBLWrWa0GPUkDCEk",
  "y": "XMcRuuoGW7CXjQdy-F5i3FeBE0x9hPLdeFdSoDd3ELmx404tLX0VRRcqzAsPhXcI",
  "alg": "ES384"
}
```

Using the above JWT values and JWKs, the complete JWT as passed in the Authorization HTTP header would be:

```
Authorization: Bearer eyJhbGciOiJFUzM4NCIsInR5cCI6IkpXVCIsImtpZCI6ImV4YW1wbGUta2lkIiwiamt1IjoiaHR0cHM6Ly9maGlyLWVoci5leGFtcGxlLmNvbS9qd2tfdXJpIn0.eyJpc3MiOiJodHRwczovL2ZoaXItZWhyLmV4YW1wbGUuY29tLyIsImF1ZCI6Imh0dHBzOi8vY2RzLmV4YW1wbGUub3JnL2Nkcy1zZXJ2aWNlcy9zb21lLXNlcnZpY2UiLCJleHAiOjE0MjI1Njg4NjAsImlhdCI6MTMxMTI4MDk3MCwianRpIjoiZWUyMmIwMjEtZTFiNy00NjExLWJhNWItOGVlYzZhMzNhYzFlIiwidGVuYW50IjoiMmRkZDZjM2EtOGU5YS00NGM2LWEzMDUtNTIxMTFhZDMwMmEyIn0.d1WfLjGRKlcWB94l9do4cM8REXeYJLL6SGUBO8VHZhfM8mwKYP70EMxJ67War4TQblEpaQrp11wx5p7oPFm2ETYgCicS84vXWEIYTdjooZdooCSDf2L8-i4awdoUwiEb
```

### Cross-Origin Resource Sharing

[Cross-origin resource sharing (CORS)](https://www.w3.org/TR/cors/) is a [World Wide Web Consortium (W3C)](https://www.w3.org/Consortium/) standard mechanism that uses additional HTTP headers to enable a web browser to gain permission to access resources from an Internet domain different from that which the browser is currently accessing.  CORS is a client-side security mechanism with well-documented security risks.

CDS Services and browser-based CDS Clients will require CORS support. A secure implementation guide for CORS is outside of the scope of this CDS Hooks specification. Organizations planning to implement CDS Hooks with CORS support are referred to the Cross-Origin Resource Sharing section of the [OWASP HTML5 Security Cheat Sheet]( https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html#cross-origin-resource-sharing).

### Update stale guidance

In the case that CDS Hooks cards are persisted, clients should take care to ensure that stale guidance does not negatively impact patient care.

CDS Services can update their previously returned guidance by returning a new set of `cards` when the service is invoked based on a different `hook`. CDS Services indicate this intent by providing multiple CDS Services with the same `id` in [discovery](services.html#discovery). Clients are recommended to remove `cards` returned by a previous invocation with the new `cards`.

*STU NOTE: We are seeking implementer feedback on how best to balance the needs of performance for implementations with the critical patient safety issues raised by the potential for stale guidance.*

Note that CDS Services will need to negotiate with CDS Clients to ensure that hooks that are required to ensure patient safety are supported by the CDS Client.
