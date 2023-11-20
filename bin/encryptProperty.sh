#!/bin/bash

################################################################################
function show_usage_and_exit() {
    cat <<'ENDHELP'
Usage:
  encryptProperty.sh [options] <env-name> <property-value>

Examples:
  encryptProperty.sh dev "P@ssw0rd"
  encryptProperty.sh -d dev "HQFYewNPyocE96Hkg8rBUg=="
  encryptProperty.sh -k "sp3cia1key" "P@ssw0rd"
  encryptProperty.sh -d -k "sp3cia1key" "y/R6lBkaJdQThRpL69JrNw=="

Options:
  -e   Encrypt the value. (default)
  -d   Decrypt the value.
  -k   Specify explicit encryption key rather than an env-name.
  -x   Enable tracing of commands as they execute.

Specify either env-name (dev), or a specific property encryption key via -k

Assumptions:
  java is on the command PATH
ENDHELP
    exit
}
if [[ "$1" == "--help" ]]; then
    show_usage_and_exit
fi
################################################################################
# TODO: move -d to be parsed in front of the propertyValue

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

JAR_URL=https://docs.mulesoft.com/downloads/mule-runtime/4.2/secure-properties-tool.jar
JAR_FILE=$(basename ${JAR_URL})

# ignore command customizations, if any
unalias curl    2> /dev/null
unalias java    2> /dev/null

if ! type java > /dev/null 2>&1; then
    echo "java is not found on the PATH" >&2
    exit 1
fi

# --------------------------------------------------
# parse command line options

cryptOp=encrypt
cmdTrace=+x

while [[ $# > 0 && "${1}" =~ ^[-+] ]]; do
    case "${1}" in
        -e) cryptOp=encrypt;    shift 1 ;;
        -d) cryptOp=decrypt;    shift 1 ;;
        -k) encryptionKey="$2"; shift 2 ;;
        -x) cmdTrace=-x;        shift 1 ;;
         *) echo "Unrecognized option: ${1}" >&2; exit 1 ;;
    esac
done

if [[ -z ${encryptionKey} ]]; then
    envName=$1
    shift 1
    case "${envName}" in
        dev) encryptionKey='fv-@%wejGEN#H4Pk' ;;
         qa) encryptionKey='fv-@%wejGEN#H4Pk' ;;
       prod) encryptionKey='HhEnKl#SSR@f8-Et25' ;;
          *) echo "Unrecognized environment name: ${envName}" >&2; exit 1 ;;
    esac
fi

propertyValue=$1
shift 1

if [[ -z ${propertyValue} || $# > 0 ]]; then
    show_usage_and_exit
fi

# --------------------------------------------------

( set -e
  cd ${BASH_DIR}

  # download the jar if not present
  if [[ ! -e ${JAR_FILE} ]]; then
    ( set ${cmdTrace}; curl ${JAR_URL} -o ${JAR_FILE} )
  fi

  ( set ${cmdTrace}
    java -cp ${JAR_FILE} com.mulesoft.tools.SecurePropertiesTool \
      string ${cryptOp} Blowfish CBC "${encryptionKey}" "${propertyValue}"
  )
)
