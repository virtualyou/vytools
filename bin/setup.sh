#!/bin/bash
###################################################################
# Copyright (c) 2023 David L. Whitehurst
# License: https://github.com/dlwhitehurst/vytools/blob/main/LICENSE
#
# Setup a VirtualYou dev environment from scratch.
#
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Welcome to the VirtualYou development setup utility.

Usage:
  (First make sure that you are git-authenticated to GitHub)
  cd ~/virtualyou  # or where you want the git working directories to live
  setup.sh [options]


Options:
    --shell     Initialize shell environment variables (bash only)
    --utils     Clone the VirtualYou utilities
    --compose   Get docker-compose and setup in isolation
    --apis      Clone the api repos
    --app       Clone the current UI application
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

while [[ $# > 0 && "${1}" =~ ^-- ]]; do
    case "${1}" in 
        --shell)    initShell=true;     noAction=false; shift 1 ;;
        --utils)    cloneUtils=true;     noAction=false; shift 1 ;;
        --compose)  initCompose=true;   noAction=false; shift 1 ;;
        --apis)     cloneApis=true;     noAction=false; shift 1 ;;
        --app)      cloneApp=true;      noAction=false; shift 1 ;;
            *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

if [[ ${noAction} == true ]]; then
    echo "No action was specified" >&2
    exit 1
fi

# --------------------------------------------------
# shell setup
echo $VY_PROJECTS

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

  cd ${VY_PROJECTS}
  mkdir docker
  cd docker
  cp ${VY_PROJECTS}/vymain/docker-compose.yaml .
fi

# --------------------------------------------------
# repo cloning

if [[ ${cloneUtils} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      git clone -b main     git@github.com:dlwhitehurst/vymain.git
      git clone -b main     git@github.com:dlwhitehurst/vyconfigs.git
      git clone -b main     git@github.com:dlwhitehurst/vydata.git
    )
fi

if [[ ${cloneApis} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      git clone -b main     git@github.com:dlwhitehurst/userauth.git
      git clone -b main     git@github.com:dlwhitehurst/personal.git
      git clone -b main     git@github.com:dlwhitehurst/medical.git
      git clone -b main     git@github.com:dlwhitehurst/financial.git
      git clone -b main     git@github.com:dlwhitehurst/administration.git

    )
fi
if [[ ${cloneApp} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      git clone -b main git@github.com:dlwhitehurst/vite-mvp.git
    )
fi

