#!/bin/bash
# Exercise each of the 4 SMARTS APIs

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  smarts.sh [options]
Examples:
  export CDX_URI=https://localhost:8443
  export WIREMOCK_URI=https://localhost:8643
  envtests/smarts.sh k8s -w
  envtests/smarts.sh k8s -h
  envtests/smarts.sh k8s +a

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

doSmarts() {
    local appMoniker=$1
    local appName=$2
    local apiPath=$3
    local mockParms=$4
    local apiQuery=$5
    echo "=========================================================================================="
    ( set -e
      if [[ ${pretestWiremock} == true ]]; then
          WIREMOCK_URL=${WIREMOCK_URI}/CFMSRestApisCnic/rest/query/ma/smarts/${appName}

          # retrieve the sample SOAP request directly from WireMock to verify that it's responding
          _curl -X GET "${WIREMOCK_URL}${mockParms}" \
            -H "Content-Type: application/xml"
      fi

      if [[ ${doHealthCheck} == true ]]; then
          # verify access
          _curl -X GET "${CDX_URI}/xapi/v2/smarts/${apiPath}/health"
      fi

      if [[ ${testEndpoint} == true ]]; then
          # retrieve the (mocked) response
          _curl -X GET "${CDX_URI}/xapi/v2/smarts/${apiPath}${apiQuery}" \
            -H "Content-Type: application/json"
      fi
    )
}

( set ${onError}
  #       moniker app-name           api-path         mock-params                        api-query
  doSmarts act  active_file          active          /2019,N25GWS,2020-06-01T09:00:00Z "?fiscalYear=2019&workCtrId=N25GWS&lastUpdate=2020-06-01T09:00:00Z"
  doSmarts fcs  fund_ctl_spend_file  fund-ctl-spend  /2020,N25GSW                      "?fiscalYear=2020&workCtrId=N25GSW"
  doSmarts rbc  reim_bill_code_file  reim-bill-code  /2020,N25GSW                      "?fiscalYear=2020&workCtrId=N25GSW"
  doSmarts ron  reim_order_nbr_file  reim-order-nbr  /2020,N25GSW                      "?fiscalYear=2020&workCtrId=N25GSW"
  echo "DONE"
)
