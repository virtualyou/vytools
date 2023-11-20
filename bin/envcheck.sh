#!/bin/bash

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  cd <parent-directory>
  envcheck.sh [options] <env-name> <api-group> [options]
Examples:
  envcheck.sh local smarts -w
  envcheck.sh local smartslh -w
  envcheck.sh +e dev sabrscb -c
  envcheck.sh -k dev advana

Options:
  +x   Disable tracing of commands (mostly curl) as they execute.
  +e   Do not halt on error. To see all errors, instead of just focusing on the first.
ENDHELP
    exit
fi
################################################################################

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ignore command customizations, if any
unalias curl    2> /dev/null
unalias grep    2> /dev/null
unalias tr      2> /dev/null

# --------------------------------------------------
# parse command line options

export curlOpts=
export hdrTrace=-i
export cmdTrace=-x
export onError=-e

while [[ $# > 0 && "${1}" =~ ^[-+] ]]; do
    case "${1}" in
        -k) curlOpts+=-k;  shift 1 ;;
        +i) hdrTrace=;     shift 1 ;;
        +x) cmdTrace=+x;   shift 1 ;;
        +e) onError=+e;    shift 1 ;;
         *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

cdxEnv=${1:-local}
shift 1

# --------------------------------------------------
# set CDX_URI & WIREMOCK_URI by source'g from cdx-configs

source ${BASH_DIR}/_cdx_env.sh ${cdxEnv}

# --------------------------------------------------

_curl() {
  ( set ${cmdTrace}
    # -f: set exit status 22 upon failure
    curl -f ${hdrTrace} ${curlOpts} "$@"
  )
  echo
}

appGroup=${1}
shift 1

source ${BASH_DIR}/envchecks/${appGroup}.sh "$@"
