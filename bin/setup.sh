#!/bin/bash
################################################################################
# WARNING: USE AT YOUR OWN RISK, WORK IN PROGRESS, REVIEW BEFORE YOU RUN.
#
# Copyright (c) 2023 VirtualYou
# License: https://github.com/virtualyou/vytools/blob/main/LICENSE
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
    --shell       Initialize shell environment variables (bash only)
    --utils       Clone the VirtualYou utilities
    --compose     Get docker-compose and setup in isolation
    --apis        Clone the api repos
    --app         Clone the current UI application
    --prep-local  Prepare application for local development
    --prep-prod   Prepare application for production deployment
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
        --shell)      initShell=true;     noAction=false; shift 1 ;;
        --utils)      cloneUtils=true;    noAction=false; shift 1 ;;
        --compose)    initCompose=true;   noAction=false; shift 1 ;;
        --apis)       cloneApis=true;     noAction=false; shift 1 ;;
        --app)        cloneApp=true;      noAction=false; shift 1 ;;
        --prep-local) prepLocal=true;     noAction=false; shift 1 ;;
        --prep-prod)  prepProd=true;      noAction=false; shift 1 ;;
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
      git clone -b main     git@github.com:virtualyou/vymain.git
      git clone -b main     git@github.com:virtualyou/vydevops.git
      git clone -b main     git@github.com:virtualyou/vydata.git
    )
fi

if [[ ${cloneApis} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      git clone -b main     git@github.com:virtualyou/userauth.git
      git clone -b main     git@github.com:virtualyou/personal.git
      git clone -b main     git@github.com:virtualyou/medical.git
      git clone -b main     git@github.com:virtualyou/financial.git
      git clone -b main     git@github.com:virtualyou/administration.git

    )
fi
if [[ ${cloneApp} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      git clone -b main git@github.com:virtualyou/vite-mvp.git
    )
fi

# --------------------------------------------------
# prepLocal

if [[ ${prepLocal} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      cd vite-mvp
      sed -i 's/https:\/\/userauth.virtualyou.info/http:\/\/localhost:3001/' vite.config.ts
      sed -i 's/https:\/\/personal.virtualyou.info/http:\/\/localhost:3002/' vite.config.ts
      sed -i 's/https:\/\/medical.virtualyou.info/http:\/\/localhost:3003/' vite.config.ts
      sed -i 's/https:\/\/financial.virtualyou.info/http:\/\/localhost:3004/' vite.config.ts
      sed -i 's/https:\/\/administration.virtualyou.info/http:\/\/localhost:3005/' vite.config.ts

      cd src/services
      sed -i 's/https:\/\/app.virtualyou.info\/userauth\/v1\//http:\/\/localhost:3000\/userauth\/v1\//' user.service.ts
      sed -i 's/https:\/\/app.virtualyou.info\/personal\/v1\/owner\//http:\/\/localhost:3000\/personal\/v1\/owner\//' personal.service.ts
      sed -i 's/https:\/\/app.virtualyou.info\/medical\/v1\/owner\//http:\/\/localhost:3000\/medical\/v1\/owner\//' medical.service.ts
      sed -i 's/https:\/\/app.virtualyou.info\/financial\/v1\/owner\//http:\/\/localhost:3000\/financial\/v1\/owner\//' financial.service.ts
      sed -i 's/https:\/\/app.virtualyou.info\/userauth\/v1\/auth\//http:\/\/localhost:3000\/userauth\/v1\/auth\//' auth.service.ts
      sed -i 's/https:\/\/app.virtualyou.info\/administration\/v1\/owner\//http:\/\/localhost:3000\/administration\/\/owner\//' administration.service.ts
    )
      echo
      echo "      ** Do not forget to pull domain from cookie session in userauth."
      echo "      ** This means that you need to comment userauth server.js file and build an image for Docker Hub."
      echo "      ** docker build -t virtualyou/userauth:0.1.0-dev"
fi

# --------------------------------------------------
# prepProd

if [[ ${prepProd} == true ]]; then
    cd $VY_PROJECTS
    ( set -ex
      cd vite-mvp
      sed -i 's/http:\/\/localhost:3001/https:\/\/userauth.virtualyou.info/' vite.config.ts
      sed -i 's/http:\/\/localhost:3002/https:\/\/personal.virtualyou.info/' vite.config.ts
      sed -i 's/http:\/\/localhost:3003/https:\/\/medical.virtualyou.info/' vite.config.ts
      sed -i 's/http:\/\/localhost:3004/https:\/\/financial.virtualyou.info/' vite.config.ts
      sed -i 's/http:\/\/localhost:3005/https:\/\/administration.virtualyou.info/' vite.config.ts

      cd src/services
      sed -i 's/http:\/\/localhost:3000\/userauth\/v1\//https:\/\/app.virtualyou.info\/userauth\/v1\//' user.service.ts
      sed -i 's/http:\/\/localhost:3000\/personal\/v1\/owner\//https:\/\/app.virtualyou.info\/personal\/v1\/owner\//' personal.service.ts
      sed -i 's/http:\/\/localhost:3000\/medical\/v1\/owner\//https:\/\/app.virtualyou.info\/medical\/v1\/owner\//' medical.service.ts
      sed -i 's/http:\/\/localhost:3000\/financial\/v1\/owner\//https:\/\/app.virtualyou.info\/financial\/v1\/owner\//' financial.service.ts
      sed -i 's/http:\/\/localhost:3000\/userauth\/v1\/auth\//https:\/\/app.virtualyou.info\/userauth\/v1\/auth\//' auth.service.ts
      sed -i 's/http:\/\/localhost:3000\/administration\/v1\/owner\//https:\/\/app.virtualyou.info\/administration\/v1\/owner\//' administration.service.ts
    )
      echo
      echo "      ** Do not forget to add domain to cookie session in userauth."
      echo "      ** This means that you need to uncomment userauth server.js file and build an image for Docker Hub."
      echo "      ** docker build -t virtualyou/userauth:0.1.0"

fi
