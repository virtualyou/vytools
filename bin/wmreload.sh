#!/bin/bash

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  wmreload.sh <api-family>
Example:
  wmreload.sh smarts

Reload WireMock stub mappings for the named group of APIs.
The api-family is specified using the same names that are recognized by eash.sh -p
ENDHELP
    exit
fi
################################################################################

# ignore any command customizations
unalias cp    2> /dev/null
unalias curl  2> /dev/null
unalias mkdir 2> /dev/null
unalias rm    2> /dev/null

apifamily=$1

[[ -z ${apifamily} ]] && { echo "api-family argument not specified." >&2; exit 1; }

# these are defined in .vyrc, which should be sourced by .bashrc or .zshrc
[[ -z ${WMROOT} ]]       && { echo "Cannot continue, WMROOT is not defined."       >&2; exit 1; }
[[ -z ${CDX_PROJECTS} ]] && { echo "Cannot continue, CDX_PROJECTS is not defined." >&2; exit 1; }

( set -e
  ( set -x
    # recreate WireMock data area
    rm -rf ${WMROOT}/{mappings,__files}
    mkdir -p ${WMROOT}/{mappings,__files}
  )

  ( set +e
    cd ${CDX_PROJECTS}

    # populate for the specified app group
    each.sh -p ${apifamily} -x +h <<'CMDS'
      cp -r src/test/resources/wiremock/mappings/* ${WMROOT}/mappings
      #tar -cC src/test/resources/wiremock/mappings . --transform "s|^./|./$IDIR-|" | tar -xC ${WMROOT}/mappings
      cp -r src/test/resources/wiremock/__files/*  ${WMROOT}/__files
CMDS
    : # clear the final exit code - always success
  )

  # TODO
  #each.sh -p smartslh -x +h <<CMDS
  #  rsync -au src/test/resources/wiremock/ ${WMROOT}/
  #CMDS

  ( set -x
    # tell WireMock to reload
    curl -X POST https://localhost:8643/__admin/reset  # clear & reload
  )
)
