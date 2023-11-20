#!/bin/bash
# Exercise each of the 3 Advana APIs
# WARNING - Running these tests adds data to the JMS queue & Redis cache

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  advana.sh
Example:
  export CDX_URI=https://localhost:8443
  envtests/advana.sh k8s

Options:
  -h   Access the /health endpoint of each API.
  +a   Skip testing the actual API endpoint.
ENDHELP
    exit
fi
################################################################################

# --------------------------------------------------
# parse command line options

export doHealthCheck=
export testEndpoint=true

while [[ $# > 0 && "${1}" =~ ^[-+] ]]; do
    case "${1}" in
        -h) doHealthCheck=true;  shift 1 ;;
        +a) testEndpoint=;       shift 1 ;;
         *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

if [[ -z "${doHealthCheck}${testEndpoint}" ]]; then
    echo "No operation specified"
    exit 0
fi

# --------------------------------------------------

( set ${onError}
  if [[ ${doHealthCheck} == true ]]; then
      # verify access
      _curl -X GET "${CDX_URI}/sapi/v1/audits/health"
      _curl -X GET "${CDX_URI}/xapi/v1/dropbox/audits/health"
      _curl -X GET "${CDX_URI}/xapi/v1/audits/health"
  fi

  if [[ ${testEndpoint} == true ]]; then
      # SAPI, Push & Pull
      _curl -X POST "${CDX_URI}/sapi/v1/audits" \
        -H "Content-Type: application/json" \
        -d '{ "uotAAI": "123456", "uotAbsAmount": "1.99", "uotAcctgPeriod_Calendar": 202004 }'
      _curl -X GET "${CDX_URI}/sapi/v1/audits"
      _curl -X GET "${CDX_URI}/sapi/v1/audits/cache"

      # XAPI Push
      _curl -X POST "${CDX_URI}/xapi/v1/dropbox/audits" \
        -H "Content-Type: application/json" \
        -d '[ { "uotAAI": "123456", "uotAbsAmount": "1.99", "uotAcctgPeriod_Calendar": 202004 } ]'

      # XAPI Pull
      _curl -X GET "${CDX_URI}/xapi/v1/audits"
      echo
      _curl -X GET "${CDX_URI}/xapi/v1/audits/cache"
  fi
)
echo "DONE"
