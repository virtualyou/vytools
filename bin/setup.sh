#!/bin/bash
# Setup a VirtualYou dev environment from scratch.

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Welcome to the VirtualYou development setup utility.

Usage:
  (First make sure that you are git-authenticated to GitHub)
  cd ~/virtualyou  # or where you want the git working directories to live
  setup.sh [options]


Options:
    --shell     Initialize shell environment variables (bash and/or zsh)
                (May prompt for sudo password while updating /etc/profile.d)
    --nodejs    Install NVM, nodejs and set version based on vyrc
    --curl      Initialize .curlrc, (mTLS settings)
    --apis      Clone the api repos
    --app       Clone the current UI application
    --api-pkg   Clone, build, and package
    --ui-pkg    Clone, build, and package
    --pushall   Push all tagged images
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
        --shell) initShell=true;     noAction=false; shift 1 ;;
         --nodejs) initNodeJS=true;      noAction=false; shift 1 ;;
         --curl) initCurl=true;      noAction=false; shift 1 ;;
        --apis)  cloneApis=true;     noAction=false; shift 1 ;;
       --app)    cloneApp=true;      noAction=false; shift 1 ;;
              *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

if [[ ${noAction} == true ]]; then
    echo "No action was specified" >&2
    exit 1
fi

# --------------------------------------------------
# OS compatibility shimming

SUDO=sudo
sed_i() { sed -i "$@"; }

if [[ "$(uname -s)" == 'CYGWIN'* ]]; then
    SUDO=
fi
if [[ "$(uname -s)" == 'Darwin'* ]]; then
    sed_i() { sed -i '' "$@"; }
fi

# --------------------------------------------------
# shell setup

if [[ ${initShell} == true ]]; then
    if [[ -e ~/.zshrc ]]; then
        echo "Adding vytools/vyrc to ~/.zshrc"
        sed_i -e '/vyrc/d' ~/.zshrc
        echo "source ${VY_PROJECTS}/vytools/vyrc" >> ~/.zshrc
    fi
    if [[ -e ~/.bashrc ]]; then
        echo "Adding vytools/vyrc to ~/.bashrc"
        sed_i -e '/vyrc/d' ~/.bashrc
        echo "source ${VY_PROJECTS}/vytools/vyrc" >> ~/.bashrc
    fi
    # copy-in user configs
    if [[ ! -e ~/.exrc ]]; then
        echo "Adding ~/.exrc (vi editor defaults)"
        cp ${VY_PROJECTS}/vytools/host-configs/~/.exrc ~
    fi
fi

# --------------------------------------------------
# NodeJS setup

if [[ ${initNodeJS} == true ]]; then
    echo "This is pending implementation."
fi

# --------------------------------------------------
# curl setup

if [[ ${initCurl} == true ]]; then
    if [[ -z ${VY_CONFIGS} ]]; then
        echo "Cannot continue, VY_CONFIGS is not defined." >&2
        exit 1
    fi
    source ${VY_CONFIGS}/.pkirc
    echo Populating ~/.curlrc
    cat > ~/.curlrc <<EOF
# mTLS keystores
--cacert ${VY_CONFIGS}/pki/cdx_cacerts.pem
--cert   ${VY_CONFIGS}/pki/cdx_keystore.pem:${CDX_KEYSTORE_PASS}
EOF
fi

# --------------------------------------------------
# repo cloning

if [[ ${cloneApis} == true ]]; then
    if [[ -z ${NODE_VERSION} ]]; then
        echo "Cannot continue, NODE_VERSION is not defined." >&2
        exit 1
    fi
    ( set -ex
      git clone -b main     git@github.com:dlwhitehurst/userauth.git
      git clone -b main     git@github.com:dlwhitehurst/personal.git
      git clone -b main     git@github.com:dlwhitehurst/medical.git
    )
fi
if [[ ${cloneApp} == true ]]; then
    if [[ -z ${NODE_VERSION} ]]; then
        echo "Cannot continue, NODE_VERSION is not defined." >&2
        exit 1
    fi
    ( set -ex
      git clone -b main git@github.com:dlwhitehurst/vite-mvp.git
    )
fi
