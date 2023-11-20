#!/bin/bash
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  init_cdxmon_ora12.sh --drop <schema-name> <admin-password>
  init_cdxmon_ora12.sh <schema-name> <admin-password> <schema-owner-password> <svc-user-password>
Examples:
  export HOST=cdxdb.crrpuwigzxgg.us-east-1.rds.amazonaws.com
  init_cdxmon_ora12.sh --drop CDX_MON_DEV NavyRules5
  init_cdxmon_ora12.sh CDX_MON_DEV NavyRules5 cdxMonDev123 cdxMonDevSvc123

Initialize the CDX Monitoring database for a given environment.
This supports Oracle 12.
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
adminPass=${2}
ownerPass=${3}
svcPass=${4}

adminCreds=admin/${adminPass}
ownerCreds=${schema}/${ownerPass}
svcCreds=${schema}_svc/${svcPass}

sqlplus1() {
    # process a SQL script, then exit
    echo quit | ( set -x; sqlplus "$@" )
}

sid=health

echo "Validating admin creds"
sqlplus1 ${adminCreds}@${HOST}/${sid}

if [[ "${mode}" == "drop" ]]; then
    ( cd src/main/resources
        sqlplus1 ${adminCreds}@${HOST}/${sid} @dcl/drop_users.sql ${schema}
    )
else
    ( set -e
      ( cd src/main/resources
        sqlplus1 ${adminCreds}@${HOST}/${sid} @dcl/drop_users.sql           ${schema}
        sqlplus1 ${adminCreds}@${HOST}/${sid} @dcl/create_schema_owner.sql  ${schema} ${ownerPass}
        sqlplus1 ${adminCreds}@${HOST}/${sid} @dcl/create_service_user.sql  ${schema} ${svcPass}
        sqlplus1 ${ownerCreds}@${HOST}/${sid} @ddl/create_tables.sql
        sqlplus1 ${ownerCreds}@${HOST}/${sid} @ddl/create_views.sql
        sqlplus1 ${ownerCreds}@${HOST}/${sid} @dcl/schema_grants.sql ${schema} ${schema}_SVC
      )
    )
fi

echo "Testing the created owner & svc creds..."
sqlplus1 ${ownerCreds}@${HOST}/${sid}
sqlplus1 ${svcCreds}@${HOST}/${sid}
