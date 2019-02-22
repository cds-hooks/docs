# Implementation Best Practices

This page serves as best practice guidance for CDS Hooks implementers. The best practices outlined here are not mandatory implementation rules; rather, they are suggested guidance. This is a living, in progress document and the best practices outlined here should not be considered absolute or complete.

## Security

The CDS Hooks security model requires thought and consideration from implementers. Security topics are never binary, are often complex, and robust implementations should factor in concepts such as risk and usability. Implementers should approach their security related development with thoughtful care.

The CDS Hooks specifications already provides some guidance in this space. The information here is supplemental to the existing specification documentation.

The CDS Hooks security model leverages several existing RFCs. These should be read and fully understood by all implementers.

- [rfc7519: JSON Web Tokens (JWT)](https://tools.ietf.org/html/rfc7519)
- [rfc7517: JSON Web Key (JWK)](https://tools.ietf.org/html/rfc7517)
- [rfc7515: JSON Web Signature (JWS)](https://tools.ietf.org/html/rfc7515)
- [rfc7518: JSON Web Algorithms (JWA)](https://tools.ietf.org/html/rfc7518)

### CDS Clients

Implementers of CDS Clients should:

**Maintain a whitelist of CDS Service endpoints that may be invoked.**

Only endpoints on the whitelist can be invoked. This ensures that CDS Clients invoke only trusted CDS Services. This is especially important since CDS Clients may send an authorization token that allows the CDS Service temporary access to the FHIR server.

**Issue secure FHIR access tokens.**

*If* a CDS Clients generates access tokens to its FHIR server, the tokens should:

- Be unique for each CDS Service endpoint.
- Be very short-lived.
- Provide the minimum necessary access for the CDS Service. This includes both SMART scopes as well as the patient(s)/data that can be accessed.

### CDS Services

#### JWT

Upon being invoked by a CDS Client, the CDS Service should first process the given JWT to determine whether to process the given request. In processing the JWT, CDS Services should:

1. Ensure that the `iss` value exists in the CDS Service's whitelist of trusted CDS Clients.
2. Ensure that the `aud` value matches the CDS Service endpoint currently processing the request.
3. Ensure that the `exp` value is not before the current date/time.
4. Ensure that the `tenant` value exists in the CDS Service's whitelist of trusted tenants (may not be applicable to all CDS Services).
5. Ensure that the JWT signature matches the public key on record with the CDS Service. See additional notes below.
6. Ensure that the `jti` value doesn't exist in the short-term storage of JWTs previously processed by this CDS Service.

Once the JWT has been deemed to be valid, the `jti` value should be stored in the short-term storage of processed JWTs. Values in this storage only need to be kept for the maximum duration of all JWTs processed by this CDS Service. If the CDS Clients are adhering to best practices, this should be no more than an hour.

Verifying the JWT signature is a critical step in establishing trust of the caller of the CDS Service. As part of the whitelist of trusted CDS Clients, information on the public key(s) used by the CDS Client should also be stored. In some cases, this public key may be shared out-of-band. In other cases, the public key may be available at a remote endpoint and cycled on a regular basis. It is this latter case in which CDS Services should maintain their own rotating cache of public keys for the CDS Client.

CDS Services should never store, share, or log JWTs to minimize the risk of theft and replay attacks. Information within the JWT (for instance, `iss`, `tenant`, `jti`) can be logged safely and is especially useful for analytics.

If a CDS Service deems a JWT to be invalid for any reason, it should not leak the details of why the JWT failed validation back to the caller. If the caller were a malicious threat actor, leaking detailed information as to what was invalid may give the threat actor guidance on how to shape future attacks. Instead, responding to the request with a HTTP 401 Unauthorized response status code without any additional information is recommended.

#### FHIR Access

CDS Services should never store, share, or log the FHIR access token (`fhirAuthorization.access_token`) given to it by the CDS Client. The access token should be treated as an extremely sensitive, transient piece of data.
