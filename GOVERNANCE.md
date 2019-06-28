# CDS Hooks Governance

- [Overview](#overview)
- [Roles](#roles)
   - [Project Management Committee](#project-management-committee)
   - [Committers](#committers)
   - [PMC Chair](#pmc-chair)
   - [Contributors](#contributors)
   - [Implementers](#implementers)
   - [The Community](#the-community)
- [Contributions](#contributions)
  - [Master branch](#master-branch)
  - [Feature branches](#feature-branches)
  - [Forks](#forks)
- [Voting and Consensus](#voting-and-consensus)
  - [Approve](#1-approve)
  - [Abstain](#expressionless-abstain)
  - [Request changes](#-1-request-changes)
  - [Consensus](#consensus)
- [Releases](#releases)
  - [Versioning](#versioning)
  - [Scope & Feedback](#scope--feedback)
- [Communication](#communication)
- [Code of Conduct](#code-of-conduct)
- [Licensing](#licensing)

## Overview

CDS Hooks is a standard for vendor agnostic remote decision support.

The CDS Hooks organization produces an API and related projects that are driven by a community of individuals with varying backgrounds. This document outlines the governance model and consensus driven process by which this community works to ensure we all are operating with the same understanding and expectations. This helps keep our community healthy and happy.

Care has been taken to separate the development process we follow from the tools. With that being said, our use of Github certainly has a great influence in how we've defined this process.

## Roles

### Committers

The committers are individuals who are recognized by merit and have a demonstrated history of contributions and commitment to the project. These individuals have write access to the codebase and are collectively responsible for the project. This includes project direction and scope, accepting contributions, and cultivating the community.

The current committers on the project are:

- [Brett Marquard](https://github.com/brettmarquard)
- [Bryn Rhodes](https://github.com/brynrhodes)
- [Dennis Patterson](https://github.com/dennispatterson)
- [Isaac Vetter](https://github.com/isaacvetter)
- [Josh Mandel](https://github.com/jmandel)
- [Kevin Shekleton](https://github.com/kpshek)


### Project Management Committee

Members of the PMC are committers who are also responsible for governing the CDS Hooks project. The PMC has primary responsibility for development of the CDS Hooks community. This includes evangelism, organizing Connectathons, and other forms of community building. The PMC also reports progress to the community and defines target feature sets for releases. Emeritus PMC members are recognized for their significant contributions to CDS Hooks and are not able to cast votes.Emeritus PMC members may be reinstated at any time upon a unanimous PMC vote. 

The PMC also is responsible for the project governance and process (including this policy).

The current PMC members are:

- [Brett Marquard](https://github.com/brettmarquard)
- [Bryn Rhodes](https://github.com/brynrhodes)
- [Isaac Vetter](https://github.com/isaacvetter)
- [Josh Mandel](https://github.com/jmandel)

Emeritus PMC members are:
- [Kevin Shekleton](https://github.com/kpshek)


### PMC Chair

The PMC Chair is a PMC member and committer who takes on the primary responsibility of ensuring the health of the project and community. The PMC Chair Additionally, the PMC Chair maintains logistical resources such as the domain name, hosting resources, and mailing list.

The current PMC Chair is - [Isaac Vetter](https://github.com/isaacvetter)

### Contributors

Anyone who has submitted a change to any code or documentation that was successfully accepted is considered a contributor. Each contributor will be recognized in the commit log as well as in the CONTRIBUTORS.md file associated with the project.

### Implementers

Implementers are those who have implemented the CDS Hooks API. Such implementations can be done locally, in a test environment, or in a production system.

### The Community

The community refers to the collective set of individuals and parties contributing to, implementing, or following the CDS Hooks project.

## Accepting New Committers and PMC Members

Any existing committer may nominate a contributor as a new committer on the project. The nominee should have a demonstrated history of contributions and commitment. Contributions can come in many forms such as code, issues, documentation, and community engagement. A nominee must receive a unanimous vote from the PMC. Upon being accepted, the PMC Chair will grant the nominee write access to the CDS Hooks repositories and announce the new committer to the mailing list.

Any current PMC member may nominate a current committer to the join the PMC. The nominee should have a demonstrated history leadership in support of the community, and must receive a unanimous vote from the PMC.

## Contributions

Anyone is welcome to contribute to the project. All contributions are public and associated to the individual(s) submitting the change.

### Master branch

The master branch must be kept in a releasable state.

Trivial changes may be committed directly to a repository. Changes deemed trivial are things like small documentation typos, ecosystem changes (eg, CI configuration, linting rules), etc. Obviously, *trivial* is subjective and anyone is welcome to comment directly on such changes or open an issue regarding them.

All other changes must be reviewed by the committers. This includes contributions from the community (contributors) as well as the current committers. We use [Github pull requests](https://help.github.com/articles/about-pull-requests/) and [Github pull request reviews](https://help.github.com/articles/about-pull-request-reviews/) to manage reviewing and merging the proposed changes.

For small changes, at least one committer must approve the change. If a committer was the author of the change being reviewed, the approval must come from a different committer. For large, significant, or breaking changes, the committers must reach consensus on the change. Like *trivial*, the notion of *small* and *large* are subjective terms. However, a breaking change should be clear and unambiguous. Note that the size of the contribution does not determine whether the change requires just one approval or consensus. Rather, the impact of the change reflects the type of review required. For instance, the addition of a single optional field to the API would be considered a significant change and would warrant consensus amongst the committers.

API changes are scrutinized far more closely than that of documentation or related code projects (like sample projects, test harnesses, etc). As such, API changes are always considered significant and require consensus from the committers.

### Feature branches

Committers should use feature branches to work on in-progress features and changes. Committers may commit directly to feature branches at any time and without prior review.

Committers can submit a pull request from their feature branch to the master branch for review.

### Forks

As contributors do not have write access to the repository, their contributions must be done from personal forks.

Contributors can submit a pull request from their fork to the upstream master branch for review.

## Voting and Consensus

Anyone is welcome to comment on proposed changes. This includes expressing their opinion on why a proposed change should or should not be approved. Ultimately, committers make the final determination on accepting a proposed change.

Committers should seek out the opinions and experiences from the broader community. It is the committers responsibility to balance the feedback from the community along with their own opinions and experiences.

Committers must express their votes as:

### :+1: Approve

The change is approved as proposed.

### :expressionless: Abstain

Abstentions can be explicit or implicit. An explicit abstain vote is an indication that voter does not have feelings one way or the other on the change. An implicit abstain vote is when no vote is received and does not imply feelings on the change.

Committers are discouraged from explicit or implicit abstentions when possible.

### :-1: Request changes

These votes ask the author to make alterations to their proposed change. This type of vote **must** clearly articulate the reasoning behind the vote and when possible, concrete details of the requested changes.

### Consensus

Consensus is defined as a general agreement between the committers. Note that consensus does not indicate a unanimous agreement between the committers, nor does it indicate a particular majority size.

At this time, consensus is purposely defined as-is and is left to the best judgment of the committers.

## Releases

### Versioning

All projects shall use [semantic versioning](http://semver.org/). Any committer can propose a release and requires the PMC to vote and reach consensus on a release. [Github milestones](https://help.github.com/articles/about-milestones/) are used to associate issues to a particular release.

### Scope & Feedback

For the API and specification, major and minor releases should be managed with a previously communicated intended scope. This helps frame upcoming releases to all stakeholders and set expectations. When the scope of a such releases are determined and a release timeframe is known, the PMC Chair is responsible for announcing plans for upcoming releases to solicit feedback from the community. These release feedback periods will vary depending on the scope of the release and should be of a sufficient length to allow the community to participate.

Fix releases of the API and specification contain bug fixes which do not warrant delay until a minor release. As such, fix releases often are not planned or have little prior planning and may not allow for similar release feedback periods.

The PMC Chair is responsible for announcing releases to the community via the mailing list.

## Communication

Communication should be done in an open and public manner. We leverage many different channels for open communication such as:

- [Mailing list](https://groups.google.com/forum/#!forum/cds-hooks)
- [Chat](https://chat.fhir.org/)
- [Github Issues](https://github.com/cds-hooks)

Sometimes, communication occurs outside of these public channels and this is okay; however, committers must summarize any private discussions and any decisions resulting from them in a public channel.

## Code of Conduct

In support of a healthy and inclusive community, we use and enforce a [code of conduct](./CODE_OF_CONDUCT.md) for all members of our community, including committers. Our code of conduct is adapted from the [Contributor Covenant](http://contributor-covenant.org/).

If you encounter any violation of these terms, please contact any member of the PMC. All reports will be kept in strict confidence and dealt with promptly.

## Licensing

All code is licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0). All documentation, including the specification itself, is licensed under the [Creative Commons Attribution 4.0 International license (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/).
