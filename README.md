# vytools

## Abstract
This is a collection of bash/zsh utilities for VirtualYou project work.

- For developers: env setup, code linting & cleaning, source file transformation, etc
- For CM: git tagging
- For testers: eg, README-CastleMock.md, README-Wiremock

### Overview
This project is a work-in-progress. Originally drafted by Chris Noe for work within a MuleSoft 
project, much of this has been and is being refactored. It was a work-in-progress when Chris 
originally started it.

Scripts:
 - `bin/setup.sh`: A script for initial setup of a CDX developer workstation.
 - `bin/indent.sh`: Apply standardized indentation to project files. This varies by file type, 
pom.xml (tabs), vs code (spaces), etc.
 - `bin/iter.sh`: A general purpose directory iterator.
 - `bin/each.sh`: A general purpose project iterator for running commands uniformly on the project 
source trees, (eg, build, deploy, git tagging).
