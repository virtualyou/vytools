#!/bin/bash
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  make-orakit.sh <Oracle-version>
Examples:
  cd cdx-mon-db-sapi
  make-orakit.sh 12
  make-orakit.sh 18

Create a tar file containing the required sql scripts for the task, and a bash script that runs them.
The supported Oracle versions are 12 and 18, for AWS RDS and for local, respectively.
ENDHELP
    exit
fi
################################################################################

ORA_VER=${1}
if [[ ! -e ${CDX_PROJECTS}/cdx-env-tools/bin/init_cdxmon_ora${ORA_VER}.sh ]]; then
    echo "Unrecognized Oracle version: ${ORA_VER}" >&2
    exit 1
fi

TARGET_DIR=${PWD}/target
KIT_NAME=ora${ORA_VER}-cdxmon-schema

( 
  KIT_PATH=${TARGET_DIR}/${KIT_NAME}
  set -x

  ( set -e
    mkdir -p ${KIT_PATH}/src/main/resources
    rm -f ${KIT_PATH}.tar

    # the SQL
    cp -r src/main/resources/{dcl,ddl}/  ${KIT_PATH}/src/main/resources

    # the script
    cp -p ${CDX_PROJECTS}/cdx-env-tools/bin/init_cdxmon_ora${ORA_VER}.sh  ${KIT_PATH}

    ( cd ${TARGET_DIR}
      tar cvf ${KIT_PATH}.tar ${KIT_NAME}
      tar tvf ${KIT_PATH}.tar
    )
  )
  rm -rf ${KIT_PATH}
)

echo "To extract and use:"
echo "  tar xvf ${KIT_NAME}.tar"
echo "  cd ${KIT_NAME}"
echo "  ./init_cdxmon_ora${ORA_VER}.sh --help"
