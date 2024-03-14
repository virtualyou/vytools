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
Project Tool Utility

Usage:
  vytool.sh [options]


Options:
    --chk-ver       (EACH << CMD) Get package.json version
    --chk-domain    (EACH << CMD) Get domain line src/app.ts

    --dclean        (WARNING) Clean all containers then all images (w/prompts)

    --dev-api       (EACH << CMD) Comment domain in cookie session
    --prod-api      (EACH << CMD) Uncomment domain in cookie session

    --pkg-api       (WARNING) Build and package APIs
    --push-api      (WARNING) Push API images

    --set-ver       (EACH << CMD) Set package.json file
    --test          Testing option
ENDHELP
    exit
fi
################################################################################

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
CALL_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" >/dev/null 2>&1 && pwd )"
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
        --chk-ver)      chkVersion=true;      noAction=false; shift 1 ;;
        --chk-domain)   chkDomain=true;       noAction=false; shift 1 ;;
        --dclean)       dockerClean=true;     noAction=false; shift 1 ;;
        --dev-api)      devApi=true;          noAction=false; shift 1 ;;
        --pkg-api)      packageApis=true;     noAction=false; shift 1 ;;
        --prod-api)     prodApi=true;         noAction=false; shift 1 ;;
        --push-api)     pushApis=true;        noAction=false; shift 1 ;;
        --push-app)     pushApp=true;         noAction=false; shift 1 ;;
        --set-ver)      setVersion=true;      noAction=false; shift 1 ;;
        --test)         testScript=true;      noAction=false; shift 1 ;;
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

    # Delete all Docker containers but mariadb
    #docker rm -f "$(docker ps -a | grep -v 'mariadb' | awk 'NR>1 {print $1}')"

    # Delete all Docker Containers
    docker rm -f "$(docker ps -aq)"

    echo "Now, deleting all images"

    # Delete all Docker images but mariadb
    #docker rmi -f "$(docker images | grep -v 'mariadb' | awk 'NR>1 {print $3}')"

    # Delete all Docker Images
    docker rmi -f "$(docker images -aq)"
  fi
fi

# --------------------------------------------------
# Set versions

if [[ ${setVersion} == true ]]; then

  if [ -z "$BUILD_VERSION" ]; then
      echo "ERROR: BUILD_VERSION is not set"
      exit 1
  fi

  #RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color

  # RESIDING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  ( set -ex
    REPLACE="$(grep version package.json | awk '{print $2}' | grep -oP '(?<=\").*?(?=\")')"
    STR="/version/s/$REPLACE/$BUILD_VERSION/g"

    sed -i $STR $CALL_DIR/package.json
    echo -e "${GREEN}SUCCESS: Set Version: $BUILD_VERSION.${NC}"
  )
fi

# --------------------------------------------------
# Set API for Local Dev (for EACH << CMD)

if [[ ${devApi} == true ]]; then

  ( set -ex
    STR="s/domain:/\/\/domain:/g"
    sed -i $STR src/app.ts
    grep --color='auto' -ir 'domain:' src/
  )

fi

# --------------------------------------------------
# Set API for Prod Hosting (for EACH << CMD)

if [[ ${prodApi} == true ]]; then

  ( set -ex
    STR="s/\/\/domain:/domain:/g"
    sed -i $STR src/app.ts
    grep --color='auto' -ir 'domain:' src/
  )

fi

# --------------------------------------------------
# Check Versions (for EACH << CMD)

if [[ ${chkVersion} == true ]]; then

  #RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m' # No Color

    if [ -e ./package.json ]; then
      # RESIDING_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
      ( #set -ex
        CALL_DIR="$( cd "$( dirname "${BASH_SOURCE[1]}" )" >/dev/null 2>&1 && pwd )"
        VERSION="$(grep version package.json | awk '{print $2}' | grep -oP '(?<=\").*?(?=\")')"
        echo -e "${GREEN}Version: $VERSION.${NC}"
      )
    fi
fi

# --------------------------------------------------
# Check Domain (for EACH << CMD)

if [[ ${chkDomain} == true ]]; then

    if [ -e ./src/app.ts ]; then
      ( #set -ex
        LINE="$(grep domain src/app.ts)"
        echo -e "$LINE"
      )
    fi
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
    cd "$VY_PROJECTS"/notification
    docker build -t dlwhitehurst/notification:"$BUILD_VERSION" .
   
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
    cd "$VY_PROJECTS"/notification
    docker push dlwhitehurst/notification:"$BUILD_VERSION"
  )
fi

# --------------------------------------------------
# Test Script
if [[ ${testScript} == true ]]; then
  echo "$VY_PROJECTS"
fi




