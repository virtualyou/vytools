#!/bin/bash
# Exercise each of the 3 SMARTS Labor History APIs

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  smartslh.sh [options]
Examples:
  export WIREMOCK_URI=http://localhost:8643
  export CDX_URI=https://localhost:8443
  envtests/smartslh.sh -x k8s -w

Options:
  -w   Pre-check WireMock before invoking each API by sending the sample SOAP request.
  -h   Access the /health endpoint of each API.
  +a   Skip testing the actual API endpoint.
ENDHELP
    exit
fi
################################################################################

# --------------------------------------------------
# parse command line options

export pretestWiremock=
export doHealthCheck=
export testEndpoint=true

while [[ $# > 0 && "${1}" =~ ^[-+] ]]; do
    case "${1}" in
        -h) doHealthCheck=true;    shift 1 ;;
        -w) pretestWiremock=true;  shift 1 ;;
        +a) testEndpoint=;         shift 1 ;;
         *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

if [[ -z "${pretestWiremock}${doHealthCheck}${testEndpoint}" ]]; then
    echo "No operation specified"
    exit 0
fi

# --------------------------------------------------

# (use isLocal to skip proxy-based)

echo "=========================================================================================="
( set ${onError}
  if [[ ${pretestWiremock} == true ]]; then
      # check the WireMock stub
      _curl -X GET "${WIREMOCK_URI}/CFMSRestApisCnic/rest/query/ma/smarts/labor_hist_trans_organization/2020,N25PRW,20200602"
      _curl -X GET "${WIREMOCK_URI}/CFMSRestApisCnic/rest/query/ma/smarts/labor_hist_trans_file/2020,N25PRW,GRRA30,20200602"
  fi

  if [[ ${doHealthCheck} == true ]]; then
      # verify access
      _curl -X GET "${CDX_URI}/sapi/v1/smarts/laborhist-trans-org/health"
      #if [[ ${CDX_ENV} == 'local' ]]; then
      #  # connect through the proxy
      #  ( set +e
      #    _curl -X GET "${CDX_URI}/xapi/v1/smarts/laborhist-trans-org/health"
      #    : # reset exit code
      #  )
      #fi
      _curl -X GET "${CDX_URI}/xapi/v1/smarts/laborhist-trans/health"
  fi

  if [[ ${testEndpoint} == true ]]; then
      # retrieve the (mocked) response
      _curl -X GET "${CDX_URI}/sapi/v1/smarts/laborhist-trans-org?fiscalYear=2020&workCtrId=N25PRW&createDate=20200602"
      #if [[ ${CDX_ENV} == 'local' ]]; then
      #  # connect through the proxy
      #  ( set +e
      #    _curl -X GET "${CDX_URI}/xapi/v1/smarts/laborhist-trans-org?fiscalYear=2020&workCtrId=N25PRW&createDate=20200602"
      #    : # reset exit code
      #  )
      #fi
      _curl -X GET "${CDX_URI}/xapi/v1/smarts/laborhist-trans?fiscalYear=2020&workCtrId=N25PRW&createDate=20200602&organization=GRRA30"
  fi
  echo "DONE"
)
