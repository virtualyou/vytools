#!/bin/bash
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  init_cdxmon_ora18.sh --drop <schema-name> <admin-password>
  init_cdxmon_ora18.sh <schema-name> <SYS-password> <schema-owner-password> <svc-user-password>
Examples:
  export HOST=localhost
  init_cdxmon_ora18.sh --drop CDX_MON_LOCAL oraPassword123
  init_cdxmon_ora18.sh CDX_MON_LOCAL oraPassword123 cdxMonLocal123 cdxMonLocalSvc123

Initialize the CDX Monitoring database for a given environment.
This supports Oracle 18+, using a PDB (pluggable database)
ENDHELP
    exit
fi
################################################################################

mode=create

while [[ $# > 0 && "$1" =~ ^[-+] ]]; do
    case "$1" in
      --drop) mode=drop; shift 1 ;;
           *) echo "Unrecognized option: ${1}" >&2;  exit ;;
    esac
done

if [[ -z "${HOST}" ]]; then
    echo "Please set the HOST variable before running this script." >&2
    exit 1
fi
if [[ ! -e "src/main/resources" ]]; then
    echo "This script needs to be run inside the relevant source directory." >&2
    exit 1
fi

schema=${1}
sysPass=${2}
ownerPass=${3}
svcPass=${4}

sysCreds=SYS/${sysPass}
ownerCreds=${schema}/${ownerPass}
svcCreds=${schema}_svc/${svcPass}

sqlplus1() {
    # process a SQL script, then exit
    echo quit | ( set -x; sqlplus "$@" )
}

sid=${schema}

echo "Validating SYS creds"
sqlplus1 ${sysCreds}@${HOST}/XE as sysdba

if [[ "${mode}" == "drop" ]]; then
    ( cd src/main/resources
      sqlplus1 ${sysCreds}@${HOST}/XE as sysdba @dcl/drop_pdb.sql ${schema}
    )
else
    ( set -e
      ( cd src/main/resources
        sqlplus1 ${sysCreds}@${HOST}/XE as sysdba @dcl/drop_pdb.sql         ${schema}
        sqlplus1 ${sysCreds}@${HOST}/XE as sysdba @dcl/create_pdb.sql       ${schema} ${ownerPass}
        sqlplus1 ${ownerCreds}@${HOST}/${sid} @dcl/create_service_user.sql  ${schema} ${svcPass}
        sqlplus1 ${ownerCreds}@${HOST}/${sid} @ddl/create_tables.sql
        sqlplus1 ${ownerCreds}@${HOST}/${sid} @ddl/create_views.sql
        sqlplus1 ${ownerCreds}@${HOST}/${sid} @dcl/schema_grants.sql ${schema} ${schema}_SVC
      )
    )
fi

echo "Testing the created owner & svc creds..."
sqlplus1 ${ownerCreds}@${HOST}/${sid}
sqlplus1 ${svcCreds}@${HOST}/${sid}
