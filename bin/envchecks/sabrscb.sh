#!/bin/bash
# Exercise each of the 4 SABRS CB APIs

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  sabrscb.sh [options]
Example:
  export CDX_URI=https://localhost:8443
  export WIREMOCK_URI=https://localhost:8643
  envtests/sabrscb.sh k8s -w -h

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

each.sh -p sabrscb <<'FUNC'
    if [[ ! -d .git ]]; then
        echo "Not a git working directory: ${PWD}" >&2
        exit 1
    fi

    baseUri=$(grep 'baseUri:' src/main/resources/api/api.raml | tr -d '\r')  # (removal of '\r' needed for Windows)
    rsrcName=${baseUri##*/}  # parse beyond final '/'
    singluar=${rsrcName%s}   # chop off trailing 's'
    mockName=${rsrcName:0:4}1

    ( set ${onError}
      if [[ ${pretestWiremock} == true ]]; then
          WIREMOCK_URL=${WIREMOCK_URI}/mock/soap/project/${mockName}/WSBPWR01Port

          # retrieve the sample SOAP request directly from WireMock to verify that it's responding
          ( set ${cmdTrace}
            curl -f ${hdrTrace} ${curlOpts} -X POST "${WIREMOCK_URL}" \
              -H "Content-Type: application/xml" \
              -d @src/test/resources/data/examples/cfms-response_valid.xml
          )
          echo
      fi

      if [[ ${doHealthCheck} == true ]]; then
          ( set ${cmdTrace}
            # verify access
            curl -f ${hdrTrace} ${curlOpts} -X GET "${CDX_URI}/sapi/v1/${rsrcName}/health"
          )
      fi

      if [[ ${testEndpoint} == true ]]; then
          # submit the sample JSON request to the API
          ( set ${cmdTrace}
            curl -f ${hdrTrace} ${curlOpts} -X POST "${CDX_URI}/sapi/v1/${rsrcName}" \
              -H "Content-Type: application/json" \
              -d @src/test/resources/data/examples/valid.json
          )
      fi
      echo
    )
FUNC
