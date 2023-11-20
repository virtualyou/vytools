# README-MySQL
MySQL, a previously open-source relational database, is being used during CDX 
development of the CDX monitoring strategy. This README outlines how to stand 
up a Docker container where MySQL (database) and Adminer (Web Admin) can be 
used for local development.

Dependencies:
- Docker
- Web Browser (optional) for ad hoc database administration

On Windows there are two options for using Docker:
- Install Docker Desktop for Windows, (which also installs Hyper-V).
- Install Docker into a hypervisor of your choice, (eg, VirtualBox, Multipass, 
etc.).

## Run MySQL as a Docker container

Run via Docker Compose
```
cd ${CDX_PROJECTS}/cdx-env-tools/docker
docker-compose up -d mysql
```

This will execute the MySQL server in a docker container for your local 
development and testing. Please note that the adminer tool was also added in 
the docker-compose.yaml. This is a web-based tool for admin over the MySQL 
database. It is part of the mysql docker offering and was added to the CDX 
env tools compose in case anyone needs it.

Any needed SQL has been added to new folder in `cdx-env-tools` (this repo) 
called ddl/ . Any database schema, procedures, or function code can be found 
there.

#### Testing the server
Using any MySQL database client, you will need the hostname e.g. localhost, 
port 3306, the user root, and password `mysqlAdmin123`. Naturally, this 
information would not be shared for production or staging environments. It is 
here for your support during development.

#### Stopping the server

Stop and remove the container
```
cd ${CDX_PROJECTS}/cdx-env-tools/docker
docker-compose rm -fsv mysql
```

##### TODOs:
##### Notes:

