#!/bin/bash

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  envcheck-all.sh [<env-name>]
Examples:
  envcheck-all.sh qa

Options:
  +e   Do not halt on error. To see all errors, instead of just focusing on the first.
ENDHELP
    exit
fi
################################################################################

# --------------------------------------------------
# parse command line args

export onError=-e

while [[ $# > 0 && "${1}" =~ ^[-+] ]]; do
    case "${1}" in
        +e) onError=+e;  shift 1 ;;
         *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

env=${1:-dev}
shift 1

# --------------------------------------------------
# check each API family

( set ${onError}

  envcheck.sh ${env} prod -h

#  envcheck.sh ${env} financial-apis -h
#  envcheck.sh ${env} medical-apis   -h
)
