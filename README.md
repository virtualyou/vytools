# CDX Environment Tools #

## Abstract
This is a collection utilities for CDX project work.

- For developers: env setup, code linting & cleaning, source file transformation, etc
- For CM: git tagging
- For testers: eg, README-CastleMock.md

### Overview

Templates:
 - `.m2/settings.xml`: Config for accessing the MS3 Maven repository. Copy this to, or integrate with your existing `~/.m2/settings.xml`.

Scripts:
 - `bin/setup.sh`: A script for initial setup of a CDX developer workstation.
 - `bin/indent.sh`: Apply standardized indentation to project files. This varies by file type, pom.xml (tabs), vs code (spaces), etc.
 - `bin/iter.sh`: A general purpose directory iterator.
 - `bin/each.sh`: A general purpose project iterator for running commands uniformly on the project source trees, (eg, build, deploy, git tagging).
# env-tools
# vytools
