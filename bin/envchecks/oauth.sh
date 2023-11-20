#!/bin/bash
# Exercise the OAuth API

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  oauth.sh [options]
Examples:
  export OAUTH_URI=https://3.226.94.174:8443
  oauth.sh k8s +a

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
        -h) doHealthCheck=true;    shift 1 ;;
        +a) testEndpoint=;       shift 1 ;;
         *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

if [[ -z "${doHealthCheck}${testEndpoint}" ]]; then
    echo "No operation specified"
    exit 0
fi

# --------------------------------------------------

curl_expect() (
    local expected=${1}
    shift 1
    set +e
    httpCode=$(
      curl -f -w"%{http_code}" "$@" 2>/dev/null
    )
    [[ ${httpCode} != ${expected} ]] && echo "Unexpected httpCode: ${httpCode}"
)

# --------------------------------------------------

( set ${onError}
      if [[ ${doHealthCheck} == true ]]; then
          # verify access
          _curl -X GET "${CDX_URI}/oauth/health"
      fi

      if [[ ${testEndpoint} == true ]]; then
          # submit the sample JSON request to the API
          _curl -X GET -u admin:admin "${CDX_URI}/oauth/clients"
      fi
      echo
)
