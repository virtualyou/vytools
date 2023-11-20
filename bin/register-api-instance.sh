#!/bin/bash
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  register-api-instance.sh <options> <artifactId> 
Example:
  register-api-instance.sh -a v1 -v 1.1.0 -s ~/.anypoint/mycreds -u https://mule.dev.kube.navy.ms3-inc.com/xapi/v1/time cdx-time

Options:
  -a          API Version (v1 default)
  -h, --help  Display help documentation
  -s          Source Anypoint credentials (ANYPOINT_USERNAME, .._PASSWORD, .._ORG, .._ENV, .._HOST)
  -v          Exchange Asset Version (1.0.0 default)
  -u          Implementation URL e.g. https://mule.dev.kube.navy.ms3-inc.com/xapi/v1/time

Notes:
  Command returns an auto-discovery id as the product of the API registration

ENDHELP
  exit
fi

####################################################################################
function register() {
  (
    set -ex
    anypoint-cli api-mgr api manage \
      --type ${API_TYPE} \
      --withProxy \
      --muleVersion4OrAbove \
      --port ${HTTP_PORT} \
      --deploymentType ${DEPLOYMENT_TYPE} \
      --path "/" \
      --scheme ${SCHEME} \
      --uri ${URI} \
      ${ASSET} ${API_INSTANCE_VERSION}
  )
}

####################################################################################
function registerAPI() {

  # Ping the Anypoint Client tool
  (
    set -ex
    ACK="$(anypoint-cli account user describe)"
  )
  rcUserRegister=$?

  # Create a new API Instance
  if [[ "${rcUserRegister}" == 0 ]]; then
    register 
    rcRegister=$?
  else
      echo "ERROR: connecting to Anypoint Client." >&2
  fi
}

####################################################################################
# Script execution

URI=https://acme.com/xapi/v1/resource                     # aligns with populated baseUri in RAML (mostly) 
API_VERSION=v1                                            # Default v1
API_INSTANCE_VERSION=1.0.0                                # Default 1.0.0
HTTP_PORT=443                                             # Hybrid, port info only in API Manager 
API_TYPE=http
DEPLOYMENT_TYPE=hybrid                                    # cloud anypoint - on-prem server
SCHEME=https                                              # HTTPS, info only in API Manager

# parse off optional flags
while [[ $# > 0 && "$1" =~ ^[-+] ]]; do
    case "$1" in
        -a) API_VERSION=${2};                     shift 2;; # default v1 
        -s) source ${2};                          shift 2;; # e.g -s ~/.anypoint/mycreds 
        -u) URI=${2};                             shift 2;; # default https://acme.com/xapi/v1/resource
        -v) API_INSTANCE_VERSION=${2};            shift 2;; # default 1.0.0
         *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

ASSET=${1}

if [[ -z ${ASSET} ]]; then
  echo "ERROR: An API artifact name must be provided. See help" >&2
else
  registerAPI
fi

if [[ ${rcRegister} == 0 ]]; then
  echo "SUCCESS: The API Instance ${ASSET} has been registered in the Anypoint API Manager."
else
  echo "ERROR: The API Asset ${ASSET} has NOT been registered in the Anypoint API Manager." >&2
fi
exit

