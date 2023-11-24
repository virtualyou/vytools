# README-MariaDB
MySQL, a previously open-source relational database, is not being used during 
VirtualYou development. MariaDB remains open-source and uses the MySQL dialect. 
This README outlines how to run a Docker container where MariaDB can be used 
for local development as a relational SQL database.

## Dependencies
- Docker

On Windows there are two options for using Docker:
- Install Docker Desktop for Windows, (which also installs Hyper-V).
- Install Docker into a hypervisor of your choice, (eg, VirtualBox, Multipass, 
etc.).

## Run MariaDB as a Docker container

Run via Docker Compose
```
cd ${VY_PROJECTS}/vytools/docker
docker-compose up -d db

# or if vytools is setup correctly use the docker-compose alias in any folder
# and ...

dc up db
```

This will execute the MariaDB server in a docker container for your local 
development and testing. Port 3306 is exposed to localhost so you can use
a DB client tool to inspect schemas and interact with the database using SQL.

Any needed SQL has been added to a folder in `vytools` (this repo) called ddl/ . 

#### Testing the server
Using any MySQL database client, you will need the hostname e.g. localhost, 
port 3306, the user root, and password `mariadbAdmin123`. Naturally, this 
information would not be shared for any hosting environments. It is here for 
your support during development of VirtualYou.

#### Stopping the server

Stop and remove the container
```
cd ${VY_PROJECTS}/vytools/docker
docker-compose rm -fsv db
```

