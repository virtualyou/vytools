#!/bin/bash
################################################################################
# WARNING: USE AT YOUR OWN RISK, WORK IN PROGRESS, REVIEW BEFORE YOU RUN.
#
# Copyright (c) 2023 VirtualYou
# License: https://github.com/virtualyou/vytools/blob/main/LICENSE
#
# This script helps with docker builds and pushes
#
# Author: David L Whitehurst
#
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
API Tools

Usage:
  apitools.sh [options]


Options:
    --dclean        Clean all containers then all images (w/prompts)
    --ver-api       Set package.json file (with each.sh)
    --pkg-api       Build and package APIs
    --pkg-app       Build and package UI application
    --test          Test script sandbox
    --push-api      Push API images
    --push-all      Push all tagged images
ENDHELP
    exit
fi
################################################################################

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
VY_PROJECTS=$( cd ${BASH_DIR}/../.. && pwd )

# Get the version number from the first positional parameter
BUILD_VERSION=$2


# ignore any command customizations
unalias cat  2> /dev/null
unalias cp   2> /dev/null
unalias git  2> /dev/null
unalias sudo 2> /dev/null

noAction=true

# --------------------------------------------------
# parse command line options

while [[ $# > 0 && "${1}" =~ ^-- ]]; do
    case "${1}" in
        --dclean)   dockerClean=true;     noAction=false; shift 1 ;;
        --ver-api)  versionApis=true;     noAction=false; shift 1 ;;
        --pkg-api)  packageApis=true;     noAction=false; shift 1 ;;
        --push-api) pushApis=true;        noAction=false; shift 1 ;;
        --app-pkg)  packageApp=true;      noAction=false; shift 1 ;;
        --test)     testScript=true;      noAction=false; shift 1 ;;
        *) echo "Unrecognized option:         ${1}" >&2; exit 1 ;;
    esac
done

if [[ ${noAction} == true ]]; then
    echo "No action was specified" >&2
    exit 1
fi


# --------------------------------------------------
# docker clean

if [[ ${dockerClean} == true ]]; then
  tmp=$(docker ps)
  echo "$tmp"

  if [[ ${tmp} == 'CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES' ]]; then
    # Prompt the user for confirmation
    read -p "Do you want to proceed? (y/n) " choice

    # Check the user's response
    case "$choice" in
      y|Y ) echo "Deleting all containers ...";;
      n|N ) echo "Exiting..."; exit;;
      * ) echo "Invalid response"; exit;;
    esac

    # Delete all Docker Containers
    ( set -ex
      docker rm -f $(docker ps -aq)
    )

    # Delete all Docker Images
    echo "Now, deleting all images"
    ( set -ex
      docker rmi -f $(docker images -aq)
    )
  else
    echo "You need to stop running Docker containers first.";
    exit;
  fi
fi

# --------------------------------------------------
# API versions

if [[ ${versionApis} == true ]]; then

  if [ -z "$BUILD_VERSION" ]; then
      echo "ERROR: BUILD_VERSION is not set"
      exit 1
  fi

  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color

  # RESIDING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  ( set -ex
    CALL_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" >/dev/null 2>&1 && pwd )"
    REPLACE="$(grep version package.json | awk '{print $2}' | grep -oP '(?<=\").*?(?=\")')"
    STR="/version/s/$REPLACE/$BUILD_VERSION/g"

    sed -i $STR $CALL_DIR/package.json
    echo -e "${GREEN}SUCCESS: Set Version: $BUILD_VERSION.${NC}"
  )
fi

# --------------------------------------------------
# API packages

if [[ ${packageApis} == true ]]; then

    if [ -z "$BUILD_VERSION" ]; then
        echo "ERROR: BUILD_VERSION is not set"
        exit 1
    fi

  ( set -ex
    cd $VY_PROJECTS/userauth
    docker build -t dlwhitehurst/userauth:$BUILD_VERSION .
    cd $VY_PROJECTS/personal
    docker build -t dlwhitehurst/personal:$BUILD_VERSION .
    cd $VY_PROJECTS/medical
    docker build -t dlwhitehurst/medical:$BUILD_VERSION .
    cd $VY_PROJECTS/financial
    docker build -t dlwhitehurst/financial:$BUILD_VERSION .
    cd $VY_PROJECTS/administration
    docker build -t dlwhitehurst/administration:$BUILD_VERSION .
    cd $VY_PROJECTS/legal
    docker build -t dlwhitehurst/legal:$BUILD_VERSION .
  )
fi

if [[ ${pushApis} == true ]]; then

    if [ -z "$BUILD_VERSION" ]; then
        echo "ERROR: BUILD_VERSION is not set"
        exit 1
    fi
  ( set -ex
    cd $VY_PROJECTS/userauth
    docker push dlwhitehurst/userauth:$BUILD_VERSION
    cd $VY_PROJECTS/personal
    docker push dlwhitehurst/personal:$BUILD_VERSION
    cd $VY_PROJECTS/medical
    docker push dlwhitehurst/medical:$BUILD_VERSION
    cd $VY_PROJECTS/financial
    docker push dlwhitehurst/financial:$BUILD_VERSION
    cd $VY_PROJECTS/administration
    docker push dlwhitehurst/administration:$BUILD_VERSION
    cd $VY_PROJECTS/legal
    docker push dlwhitehurst/legal:$BUILD_VERSION
  )
fi

# --------------------------------------------------
# Test Script
if [[ ${testScript} == true ]]; then
  echo $BUILD_VERSION
fi

# --------------------------------------------------
# UI package
if [[ ${packageApp} == true ]]; then
  echo $BUILD_VERSION
  echo "This is under construction."
fi

