#!/bin/bash
################################################################################
# WARNING: USE AT YOUR OWN RISK, WORK IN PROGRESS, REVIEW BEFORE YOU RUN.
#
# VirtualYou Project
# Copyright 2023 David L Whitehurst
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# vytool.sh
#
# Daily development utilities
#
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
API Tools

Usage:
  apitools.sh [options]


Options:
    --app-local     (WARNING) Prep for local dist (NGINX) testing
    --app-prod      (WARNING) Prep for production dist (NGINX) release
    --dclean        (WARNING) Clean all containers then all images (w/prompts)
    --pkg-api       Build and package APIs
    --pkg-app       Build and package UI application
    --push-api      Push API images
    --push-all      Push all tagged images
    --release-local Release application for local testing (NGINX)
    --release-prod  Release application for production hosting (NGINX)
    --test          Testing option
    --ver-api       Set package.json file (with each.sh)
ENDHELP
    exit
fi
################################################################################

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
VY_PROJECTS=$( cd "${BASH_DIR}"/../.. && pwd )

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

while [[ $# -gt 0 && "${1}" =~ ^-- ]]; do
    case "${1}" in
        --dclean)       dockerClean=true;     noAction=false; shift 1 ;;
        --ver-api)      versionApis=true;     noAction=false; shift 1 ;;
        --pkg-api)      packageApis=true;     noAction=false; shift 1 ;;
        --pkg-app)      packageApp=true;      noAction=false; shift 1 ;;
        --push-api)     pushApis=true;        noAction=false; shift 1 ;;
        --push-app)     pushApp=true;         noAction=false; shift 1 ;;

        --test)         testScript=true;      noAction=false; shift 1 ;;

        --app-local)    appLocal=true;        noAction=false; shift 1 ;;
        --app-prod)     appProd=true;         noAction=false; shift 1 ;;

        --release-local)    relLocal=true;        noAction=false; shift 1 ;;
        --release-prod)     relProd=true;         noAction=false; shift 1 ;;

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
      docker rm -f "$(docker ps -aq)"
    )

    # Delete all Docker Images
    echo "Now, deleting all images"
    ( set -ex
      docker rmi -f "$(docker images -aq)"
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

    sed -i "$STR $CALL_DIR"/package.json
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
    cd "$VY_PROJECTS"/userauth
    docker build -t dlwhitehurst/userauth:"$BUILD_VERSION" .
    cd "$VY_PROJECTS"/personal
    docker build -t dlwhitehurst/personal:"$BUILD_VERSION" .
    cd "$VY_PROJECTS"/medical
    docker build -t dlwhitehurst/medical:"$BUILD_VERSION" .
    cd "$VY_PROJECTS"/financial
    docker build -t dlwhitehurst/financial:"$BUILD_VERSION" .
    cd "$VY_PROJECTS"/administration
    docker build -t dlwhitehurst/administration:"$BUILD_VERSION" .
    cd "$VY_PROJECTS"/legal
    docker build -t dlwhitehurst/legal:"$BUILD_VERSION" .
  )
fi

if [[ ${pushApis} == true ]]; then

    if [ -z "$BUILD_VERSION" ]; then
        echo "ERROR: BUILD_VERSION is not set"
        exit 1
    fi
  ( set -ex
    cd "$VY_PROJECTS"/userauth
    docker push dlwhitehurst/userauth:"$BUILD_VERSION"
    cd "$VY_PROJECTS"/personal
    docker push dlwhitehurst/personal:"$BUILD_VERSION"
    cd "$VY_PROJECTS"/medical
    docker push dlwhitehurst/medical:"$BUILD_VERSION"
    cd "$VY_PROJECTS"/financial
    docker push dlwhitehurst/financial:"$BUILD_VERSION"
    cd "$VY_PROJECTS"/administration
    docker push dlwhitehurst/administration:"$BUILD_VERSION"
    cd "$VY_PROJECTS"/legal
    docker push dlwhitehurst/legal:"$BUILD_VERSION"
  )
fi

# --------------------------------------------------
# Test Script
if [[ ${testScript} == true ]]; then
  echo "$VY_PROJECTS"
fi

# --------------------------------------------------
# UI package
if [[ ${packageApp} == true ]]; then
  echo "$BUILD_VERSION"
  echo "This is under construction."
fi

# --------------------------------------------------
# Prepare App for Local (NGINX)
if [[ ${appLocal} == true ]]; then
  echo "Local dist configuration (NGINX)"
  OLD="$( grep -o -m 1 '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' "${VY_PROJECTS}"/app/nginx.conf )"
  echo "$OLD"

  IP="$( ip route get 8.8.8.8 | grep -oP 'src \K[^ ]+' )"
  echo "$IP"
  STR="s/$OLD/$IP/g"
  echo "$STR"

  sed -i "$STR" "${VY_PROJECTS}"/app/nginx.conf
fi

# --------------------------------------------------
# Release Local
if [[ ${relLocal} == true ]]; then
    if [ -z "$BUILD_VERSION" ]; then
        echo "ERROR: BUILD_VERSION is not set"
        exit 1
    fi

    PROXY="$(grep -m 1 proxy_pass "${VY_PROJECTS}"/app/nginx.conf | awk '{print $2}')"

    echo "Pre-Release Checklist: "
    echo "  - nginx configuration shows $PROXY"
    if [ -e "${VY_PROJECTS}"/app/.env ]; then
      echo "  - .env file exists"
    else
      echo "  - .env file does not exist"
    fi
    echo
    # Prompt the user for confirmation
    read -p "Do you want to proceed? (y/n) " choice

    # Check the user's response
    case "$choice" in
      y|Y ) echo "Building, packaging, tagging, and pushing version $BUILD_VERSION for local testing (NGINX).";;
      n|N ) echo "Exiting..."; exit;;
      * ) echo "Invalid response"; exit;;
    esac

    # Point of NO RETURN
    ( # set -ex
      cd "${VY_PROJECTS}"/app
      rm -rf dist
      npm run build
    # Check if command failed
      if [ $? -ne 0 ]; then
        echo "ERROR: Something failed, consider set -ex and run again."
        exit;
      fi

      docker build -t dlwhitehurst/app:$BUILD_VERSION .
      # Check if command failed
      if [ $? -ne 0 ]; then
        echo "ERROR: Something failed, consider set -ex and run again."
        exit;
      fi

      docker push dlwhitehurst/app:"$BUILD_VERSION"
      # Check if command failed
      if [ $? -ne 0 ]; then
        echo "ERROR: Something failed, consider set -ex and run again."
        exit;
      fi

      echo "SUCCESS: dlwhitehurst/app:$BUILD_VERSION now resides at https://hub.docker.com/dlwhitehurst."
    )


fi

# --------------------------------------------------
# Prepare App for Prod (NGINX)
if [[ ${appProd} == true ]]; then
  echo "Production dist prep (NGINX)"
fi

# --------------------------------------------------
# Release Prod
if [[ ${relProd} == true ]]; then
  echo "Production dist release (NGINX)"
fi
