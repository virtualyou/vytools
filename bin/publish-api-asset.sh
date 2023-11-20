#!/bin/bash
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  publish-api-asset.sh [options] <artifactId>
Example:
  publish-api-asset.sh -a v1 -v 1.0.0 -s ~/.anypoint/mycreds -b master cdx-oauth-provider

Options:
  -a            API Version (v1 default)
  -b            Branch to create upload zip
  --drop        Quickly delete assets using each.sh
  -h, --help    Display help documentation
  -s            Source Anypoint credentials
  -v            Exchange Asset Version (1.0.0 default) 

Assumptions:
   Anypoint credentials are available to the shell.

ENDHELP
  exit
fi

####################################################################################
function deleteFromExchange() {
  API_VERSION="v1"
  ASSET_IDENTIFIER="6ff73618-f380-4f93-b293-e1fcf4af8fa0/${ASSET}/${ASSET_VERSION}" # e.g. <businessGroupId>/<assetName>/<assetVersion>

  # Ping the Anypoint Client tool
  ( set -ex
    # does not work when ack removed ... try it
    ack="$(anypoint-cli account user describe)"
  )

  rcUserDelete=$?

  # Create a new API Instance
  if [[ "${rcUserDelete}" == 0 ]]; then
    assetDelete
    echo "SUCCESS: Anypoint asset $ASSET has been deleted from Exchange."
  else
    echo "ERROR: An Anypoint Client connection could not be obtained." >&2
    echo "HINT: Did you remember to source your credentials?"
  fi
}

####################################################################################
function assetDelete() {
  (
    set -ex
     # NOTE: the GUID on the front of the asset identifier is the group id of the Navy-FMP Business organization
     anypoint-cli exchange asset delete ${ASSET_IDENTIFIER} 
  )

  rcDelete=$?

  if [[ "${rcDelete}" == 0 ]]; then
    echo "SUCCESS: Exchange Asset ${ASSET_IDENTIFIER} deleted."
    exit 
  else
    echo "ERROR: Anypoint-cli tool failure." >&2
    exit -1
  fi
}

####################################################################################
function uploadExchange() {
  API_VERSION="v1"
  ASSET_IDENTIFIER="6ff73618-f380-4f93-b293-e1fcf4af8fa0/${ASSET}/${ASSET_VERSION}" # e.g. <businessGroupId>/<assetName>/<assetVersion>
 
  FILEPATH=$(pwd)/${ASSET}/src/main/resources/api/api.zip
  
  # Ping the Anypoint Client tool
  ( set -ex
    # does not work when ack removed ... try it
    ack="$(anypoint-cli account user describe)"
  )

  rcUserUpload=$? 

  # Create a new API Instance
  if [[ "$rcUserUpload" == 0 ]]; then
    assetUpload 
  else
    echo "ERROR: An Anypoint Client connection could not be obtained." >&2
    echo "HINT: Did you remember to source your credentials?"
  fi
}

####################################################################################
function assetUpload() {
  (
    set -ex
     # NOTE: the GUID on the front of the asset identifier is the group id of the Navy-FMP Business organization
     # and the last argument is the full path to the Archive.zip
     anypoint-cli exchange asset upload \
        --classifier raml \
        --apiVersion $API_VERSION \
        --name $ASSET $ASSET_IDENTIFIER $FILEPATH

  )
  
  rcUpload=$?
 
  if [[ "$rcUpload" == 0 ]]; then
    echo "SUCCESS: Exchange Asset published."
  else
    echo "ERROR: Anypoint-cli tool failure." >&2
    exit -1
  fi
}

####################################################################################
function publishZip() {
  ( set -ex
    cd src/main/resources/api
    zip -r api *
  )
}

####################################################################################
function cloneAndZip() {
  # clone Repo
  if [[ -z "$ASSET" ]]; then
    echo "ERROR: Missing API artifactId. See --help" >&2
    exit
  fi
  
  if [[ -z "$branch" ]]; then
    echo "ERROR: Missing checkout branch. See --help" >&2
    exit
  fi
  
 ( set -ex
    if [[ -d "${ASSET}" ]]; then
      echo "${ASSET} directory exists ... removing before clone"
      rm -rf ${ASSET}
    fi
    git clone -b ${branch} --single-branch https://bitbucket.org/navyfmp/${ASSET}.git ${ASSET}
    cd ${ASSET}
    publishZip  
  )
}

####################################################################################
function cleanUpClone() {
  ( set -ex
    cd $(pwd)
    rm -rf ${ASSET}
  )
}

####################################################################################
# Script execution

API_VERSION=v1
ASSET_VERSION=1.1.0

# parse off optional flags
while [[ $# > 0 && "$1" =~ ^[-+] ]]; do
    case "$1" in
         -a) API_VERSION=${2};                      shift 2 ;; # default v1
         -b) branch=${2};                           shift 2 ;; 
     --drop) drop=YES;                              shift 1 ;;
         -s) source ${2};                           shift 2 ;;
         -v) API_INSTANCE_VERSION=${2};             shift 2 ;; # default v1.0.0
          *) echo "Unrecognized option: ${1}" >&2;  exit 1 ;;
    esac
done

ASSET=${1}

if [[ -z ${ASSET} ]]; then 
  echo "ERROR: An API artifact name must be provided. See help" >&2
else
  if [[ ${drop} == YES ]]; then
    deleteFromExchange
    exit
  fi
 
  cloneAndZip
  uploadExchange
  cleanUpClone

fi    

if [[ ${rcUpload} == 0 ]]; then
  echo "SUCCESS: The API Asset ${ASSET} has been uploaded and published in MuleSoft Exchange."
else
  echo "ERROR: The API Asset ${ASSET} was not uploaded and published in MuleSoft Exchange." >&2
fi
exit 

