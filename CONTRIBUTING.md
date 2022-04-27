# Contributing
Thank you for your interest in contriuting to ResidueFree!

As noted in the README, this software was primarily developed as an implementation artifact of an academic architecture,
and this repo was initially created to get through academic peer-review. However, we (ok, I) have not had as much time
to build or maintain this as I would like (I have never worked on ResidueFree as part of a paid position, nor does my
current job pay me for my side-projects). As such, any contributions made by the community are likely an improvement
over the lack of work I have been able to put in since the associated paper was published. 

That said, I do plan on maintaining ResidueFree for the time being and ensuring that it continues to run as intended.
Some quick guidelines:

A ResidueFree implementation for MacOS is under development, though also being worked on by a *very* part-time researcher.
To support that implementation, see https://github.com/EADMBtheAmazing/residuefree.

* For issues within a supported OS (currently only Ubuntu), please create an issue and identify whether it's an
unsupported application, edge-case residue left on the filesystem, or other bug. Since ResidueFree is designed
to prove a filesystem wide negative (that an application did *not* do something, it is infeasible to establish
a CI pipeline or other automated checks. Please describe, with as much detail, code, or artifacts as possible,
the actions taken to generate the issue, and the version of the OS and application(s) in question.

* For pull requests adding a new feature or fixing an issue to a supported OS, link to the issue if applicable,
describe the new feature or fix, and state which OS version(s) changes were tested on. Again, since CI checks
are not feasible, describe actions taken to confirmthat the change does not reduce ResidueFree's privacy guarantees 
(the complete forensic examination used to assess ResidueFree in the paper is not necessary, but please take steps 
providing reasonable assurance that your change is not leaving any information on disk). If possible, provide as much
detail or artifacts as possible to support the claim that privacy controls are not weakened by the change.

* For implementation's supporting a new OS, please create an issue to alert me (or any future maintainers), and we will
work with you to either add it as a new branch to this repo or direct future contributors to your repository, based on
how different your implementation may be and what your preferences are for your implementation
