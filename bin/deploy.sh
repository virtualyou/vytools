#!/bin/bash
# Usage
#   deploy.sh [-x|+x]

# ignore command customizations, if any
unalias cp    2> /dev/null
unalias head  2> /dev/null
unalias ls    2> /dev/null

# parse command line options
cmdTrace="set +x"
while [[ ${1} =~ ^[-+] ]]; do
    case "${1}" in
     [-+]x) cmdTrace="set ${1}"; shift 1 ;;
         *) echo "$(basename ${BASH_SOURCE}): Unrecognized option: $1" >&2; exit 1 ;;
    esac
done

if [[ $(basename ${PWD}) == 'cdx-mule-domain' ]]; then
    latestJar=$(ls -t ${PWD}/target/*-SNAPSHOT-mule-domain.jar |head -1)
    ( set -e; $cmdTrace
      cp ${latestJar} ${MULE_HOME}/domains
    )
else
    latestJar=$(ls -t ${PWD}/target/*-SNAPSHOT-mule-application.jar |head -1)
    ( set -e; ${cmdTrace}
      cp ${latestJar} ${MULE_HOME}/apps
    )
fi
