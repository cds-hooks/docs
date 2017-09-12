# Security

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
