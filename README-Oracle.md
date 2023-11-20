# Oracle Installation

## Local Oracle instance

For licensing reasons, Oracle does not provide an out-of-the-box Docker image,
and therefore you need to build it locally - a time-consuming process.

A Docker Compose service called `oracle` is defined in the `cdx-env-tools` repo.
See [docker-compose.yaml](https://bitbucket.org/navyfmp/cdx-env-tools/src/dev/docker/docker-compose.yaml).

Host minimums, (crucial is using a VM):
- 25GB disk
- 8GB memory
- Docker 17.09+

#### Docker build steps

Create the local storage directory area:
```
setup.sh --storage
mkdir -p ${CDX_PROJECTS}/cdx-storage/oracle/oradata
chmod o+w ${CDX_PROJECTS}/cdx-storage/oracle/oradata/
```

Run via Docker Compose
```
git clone https://github.com/marcelo-ochoa/docker-images.git ${CDX_PROJECTS}/oracle/docker-images
cd ${CDX_PROJECTS}/cdx-env-tools/docker/oracle
docker-compose up -d oracle
docker-compose logs -f oracle
# do not interrupt until seeing: "DATABASE IS READY TO USE", (45 min - 1.5 hours)

# then kill log tailing via ^C keypress
docker-compose rm -sf oracle  # down
```

## SQLPlus

SQL Plus is the Oracle database client tool, and is required to perform administrative tasks on an Oracle database.
It's part of the Oracle Instance Client tools.
Links and installation directions are provided for each platform here:
(Note that the step-by-step installation instructions are the bottom of each platform-specific page.)
https://www.oracle.com/database/technologies/instant-client/downloads.html

In a nutshell, to install SQLPlus, you need to unzip the "Basic Package",
and then unzip the "SQLPlus Package" into the same directory - effectively a merge of the contents of both zip files.
Then add that directory to your `PATH` variable.

### SQLPlus Usage Notes

To do a quick check that sqlplus is functioning:
```
sqlplus system/oraPassword123@localhost/XE
select sysdate from dual;
quit
```

Note that once the database is operational,
you can use DataGrip, SquirrelSQL, DBeaver, etc. for every day database tasks.
But SQLPlus is required for the initial provisioning tasks outlined.

SQLPlus differs from the more generic JDBC CLI tools.
It could be described as a high-level shell for the input of, not just SQL,
but also development and administrative commands.
