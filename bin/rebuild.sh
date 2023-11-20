#!/bin/bash
# Reset the local maven repo and do a clean rebuild.
# Usage:
#   export ENV=<env-name>  # (optional, override mvn -Denv=local)
#   rebuild.sh [-x|+x]

# ~8 min including MUnit tests (assuming warmed-up local maven repo)
# ~19 min on an empty local maven repo (pulls ~0.5 GB)

MVN_OPTS="-Denv=${ENV:-local}"

# ignore command customizations, if any
unalias rm   2> /dev/null
unalias mvn  2> /dev/null

# parse command line options
cmdTrace="set +x"
while [[ ${1} =~ ^[-+] ]]; do
    case "${1}" in
     [-+]x) cmdTrace="set ${1}"; shift 1 ;;
         *) echo "$(basename ${BASH_SOURCE}): Unrecognized option: $1" >&2; exit 1 ;;
    esac
done

if [[ $(basename ${PWD}) == 'cdx-mule-domain' ]]; then
    ( set -e; $cmdTrace
      rm -rf ~/.m2/repository/cdx
      mvn clean package install ${MVN_OPTS} "$@"
    )
else
    ( set -e; $cmdTrace
      mvn clean package ${MVN_OPTS} "$@"
    )
fi
