#!/bin/bash
###################################################################
# Copyright (c) 2023 David L. Whitehurst
# License: https://github.com/dlwhitehurst/vytools/blob/main/LICENSE
#
# This script helps with docker builds and pushes
#
# Author: David L Whitehurst
#
###############################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Welcome to the VirtualYou Tool utility.

Usage:
  tool.sh [options]


Options:
    --dclean    Clean all containers then all images (w/prompts)
    --pkg-api   Build and package APIs
    --pkg-app   Build and package UI application
    --test      Test script sandbox
    --push-api  Push API images
    --push-all  Push all tagged images
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
# API packages
if [[ ${packageApis} == true ]]; then

#  BUILD_VERSION=0.1.0

  cd $VY_PROJECTS
  ( set -ex
    cd userauth
    docker build -t dlwhitehurst/userauth:$BUILD_VERSION .
    cd ../personal
    docker build -t dlwhitehurst/personal:$BUILD_VERSION .
    cd ../medical
    docker build -t dlwhitehurst/medical:$BUILD_VERSION .
    cd ../financial
    docker build -t dlwhitehurst/financial:$BUILD_VERSION .
    cd ../administration
    docker build -t dlwhitehurst/administration:$BUILD_VERSION .
  )
fi

if [[ ${pushApis} == true ]]; then

#  BUILD_VERSION=0.1.0

  cd $VY_PROJECTS
  ( set -ex
    cd userauth
    docker push dlwhitehurst/userauth:$BUILD_VERSION
    cd ../personal
    docker push dlwhitehurst/personal:$BUILD_VERSION
    cd ../medical
    docker push dlwhitehurst/medical:$BUILD_VERSION
    cd ../financial
    docker push dlwhitehurst/financial:$BUILD_VERSION
    cd ../administration
    docker push dlwhitehurst/administration:$BUILD_VERSION
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

