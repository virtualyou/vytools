#!/bin/bash
################################################################################
# WARNING: USE AT YOUR OWN RISK, WORK IN PROGRESS, REVIEW BEFORE YOU RUN.
#
# VirtualYou Project
# Copyright 2023,2024 David L Whitehurst
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
# setup.sh
#
# Setup a VirtualYou dev environment from scratch.
#
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Welcome to the VirtualYou development setup utility.

Usage:
  ( First make sure that you are git-authenticated to GitHub )
  cd ~/virtualyou  # or where you want the git working directories to live
  setup.sh [options]


Options:
    --shell       Initialize shell environment variables (bash only)
    --utils       Clone the VirtualYou utilities
    --compose     Get docker-compose and setup in isolation

    --apis        Clone the api repos
    --app         Clone the current UI application
    --site	      Clone the website

    --del-apis    Delete the APIs
    --del-app     Delete the Application
ENDHELP
    exit
fi
################################################################################

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"
VY_PROJECTS=$( cd ${BASH_DIR}/../.. && pwd )

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
        --shell)      initShell=true;     noAction=false; shift 1 ;;
        --utils)      cloneUtils=true;    noAction=false; shift 1 ;;
        --compose)    initCompose=true;   noAction=false; shift 1 ;;
        --apis)       cloneApis=true;     noAction=false; shift 1 ;;
        --app)        cloneApp=true;      noAction=false; shift 1 ;;
        --del-apis)   delApis=true;       noAction=false; shift 1 ;;
        --del-app)    delApp=true;        noAction=false; shift 1 ;;

        --site)       cloneSite=true;     noAction=false; shift 1 ;;
            *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

if [[ ${noAction} == true ]]; then
    echo "No action was specified" >&2
    exit 1
fi

# --------------------------------------------------
# shell setup
#

if [[ ${initShell} == true ]]; then
    if [[ -e ~/.bashrc ]]; then
        echo "Adding vytools/vyrc to ~/.bashrc"
        sed -i '/vyrc/d' ~/.bashrc
        echo "source ${VY_PROJECTS}/vytools/vyrc" >> ~/.bashrc
    fi
fi

# --------------------------------------------------
# docker-compose setup

if [[ ${initCompose} == true ]]; then
  echo "BASH_DIR is $BASH_DIR"
  echo "VY_PROJECTS is ${VY_PROJECTS}"

  ( set -ex 
    cd ${VY_PROJECTS}
    mkdir docker
    cd docker
    cp ${VY_PROJECTS}/vymain/docker-compose.yaml .
  )

fi

# --------------------------------------------------
# clone utils

if [[ ${cloneUtils} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      git clone -b main     git@github.com:virtualyou/vymain.git
      git clone -b main     git@github.com:virtualyou/vydevops.git
      git clone -b main     git@github.com:virtualyou/vydata.git
    )
fi

# --------------------------------------------------
# clone apis

if [[ ${cloneApis} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      git clone -b main     git@github.com:virtualyou/userauth.git
      git clone -b main     git@github.com:virtualyou/personal.git
      git clone -b main     git@github.com:virtualyou/medical.git
      git clone -b main     git@github.com:virtualyou/financial.git
      git clone -b main     git@github.com:virtualyou/administration.git
      git clone -b main     git@github.com:virtualyou/legal.git
      git clone -b main     git@github.com:virtualyou/notification.git
      git clone -b main     git@github.com:virtualyou/speech.git
      git clone -b main     git@github.com:virtualyou/business.git

    )
fi

# --------------------------------------------------
# clone app

if [[ ${cloneApp} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      git clone -b main git@github.com:virtualyou/app.git
    )
fi

if [[ ${cloneSite} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      git clone -b main git@github.com:virtualyou/site.git
    )
fi

# --------------------------------------------------
# delete apis

if [[ ${delApis} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      rm -rf userauth
      rm -rf personal
      rm -rf medical
      rm -rf financial
      rm -rf administration
      rm -rf notification
      rm -rf legal
      rm -rf speech
      rm -rf business
    )
fi

# --------------------------------------------------
# delete app

if [[ ${delApp} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      rm -rf app
    )
fi
