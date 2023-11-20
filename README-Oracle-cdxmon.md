# CDX Monitoring Oracle Setup

These are the instructions for configuring Oracle as it relates to the CDX Monitoring system.
The provided steps define the Oracle schema for a given environment, (local, DEV, QA, PROD, etc).

## Prerequisites

The setup will be done using SQL Plus, the Oracle database client tool.
Instructions for this can be found here: 
https://bitbucket.org/navyfmp/cdx-env-tools/src/dev/README-Oracle.md  

For a local developer workstation, two repos are needed to perform the steps:

- cdx-env-tools, where the init scripts are maintained
- cdx-mon-db-sapi, where the DCL & DDL is maintained (schema definition and control SQL)

For AWS RDS, you need the latest ora12-cdxmon-schema.tar, (which is built via make-orakit.sh).

## Process Overview

The Oracle administrative user, (SYS), creates two users, (eg, CDX_MON_DEV & CDX_MON_DEV_SVC). 
The first user is the schema owner, with privileges to define and alter its schema.
The second user is granted SELECT, INSERT, UPDATE, and DELETE on that schema.
The later user is the "service" user that is used by CDX monitoring SAPI to access the database.

## Initialize the CDX Monitoring database schema

This assumes that the Oracle database is running and accessible via SQL Plus.

### For a local developer workstation

This database is an Oracle 18C XE Docker image, for a developer working locally.

Drop and re-create the CDX Monitoring schema, and populate with initial data:
```
cd cdx-mon-db-sapi
export HOST=localhost
init_cdxmon_ora18.sh CDX_MON_LOCAL oraPassword123 cdxMonLocal123 cdxMonLocalSvc123
sqlplus CDX_MON_LOCAL_SVC/cdxMonLocalSvc123@localhost/CDX_MON_LOCAL @src/test/resources/dml/LOCAL_apis.sql
```

### For Internal environments (AWS RDS Oracle)

This database is hosted as an Oracle 12C Enterprise RDS image.

This assumes that you have ora12-cdxmon-schema.tar, built from the latest cdx-mon-db-sapi,
plus the environment-specific data file, eg, DEV_apis.sql.

#### For DEV

To drop and re-create the CDX Monitoring schema and populate with initial data:
```
tar xvf ora12-cdxmon-schema.tar
export HOST=cdxdb.crrpuwigzxgg.us-east-1.rds.amazonaws.com
cd orakit-cdxmon-schema
./init_cdxmon_ora12.sh CDX_MON_DEV NavyRules5 cdxMonDev123 cdxMonDevSvc123
sqlplus CDX_MON_DEV_SVC/cdxMonDevSvc123@${HOST}/health @src/test/resources/dml/DEV_apis.sql
```

#### For QA

To drop and re-create the CDX Monitoring schema and populate with initial data:
```
tar xvf ora12-cdxmon-schema.tar
cd orakit-cdxmon-schema
export HOST=cdxdb.crrpuwigzxgg.us-east-1.rds.amazonaws.com
./init_cdxmon_ora12.sh CDX_MON_QA NavyRules5 cdxMonQa123 cdxMonQaSvc123
sqlplus CDX_MON_QA_SVC/cdxMonQaSvc123@${HOST}/health @src/test/resources/dml/QA_apis.sql
```

## CDX Monitoring database is now ready

A new pluggable database, (eg: `CDX_MON_LOCAL`), has been created and configured.

At this point the database can be accessed via JDBC using your preferred database client.
Example connection info:

- host = localhost
- port = 1521
- SID = CDX_MON_LOCAL
- user = CDX_MON_LOCAL_SVC
- password = cdxMonLocalSvc123

Example JDBC string: `jdbc:oracle:thin:@localhost:1521/cdx_mon_local`

The local development database schema, views, and corresponding test data are designed to be turn-key.
The entire schema can be dropped and completely reloaded using these scripts.

Probe sftp from inside the container (Oracle 18)
```
cd $CDX_PROJECTS/cdx-env-tools/docker/oracle
docker-compose exec oracle bash

# check disk utilization
ls -al /opt/oracle/oradata/XE/CDX_MON_DEV/
```
