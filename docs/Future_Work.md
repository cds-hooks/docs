# Overview

This section describes planned future work.


## CDS Decisions

In addition to cards, a CDS service may also return **decisions** — but only
after a user has interacted with the service via an *app link card*.
Returning a decision allows the the CDS service to communicate the user's choices  to the EHR without displaying an additional card.  For
example, a user might launch a hypertension management app, and upon
returning to the EHR's prescription page she expects her new blood pressure
prescription to "just be there". By returning a decision *instead of a card*,
the CDS service achieves this expected behavior. (*Note:* To return a
decision after a user interaction, the CDS service must maintain state
associated with the request's `hookInstance`;
when the EHR invokes the hook for a second time with the same
`hookInstance`, the service can respond with decisions on as well as cards.)
