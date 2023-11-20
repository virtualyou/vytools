# SFTP Server #
The NERP work requires an SFTP server with inbound and outbound file areas.
This README outlines how to standup an SFTP service locally for daily development activities.

Dependencies:

- Docker
- sftp client

On Windows there are two options for using Docker:

- Install Docker Desktop for Windows, (which also installs Hyper-V).
- Install Docker into a hypervisor of your choice, (eg, VirtualBox).

## Run SFTP as a Docker container

Create the local storage directory area:
```
setup.sh --storage
mkdir -p ${CDX_STORAGE}/sftp/nerp/toCFMS
mkdir -p ${CDX_STORAGE}/sftp/nerp/toNavyERP
```

Run via Docker Compose
```
cd ${CDX_PROJECTS}/cdx-env-tools/docker
docker-compose up -d sftp
docker-compose logs --tail 100 -f sftp
```

## Configure ssh client for SFTP access

The Linux sftp command uses ssh for connectivity, so files in your `~/.ssh` directory need to be properly configured.
(These very specific file permission settings are crucial.)

Configure ssh client key, and trust the SFTP host key:
```
chmod go-w ~
mkdir ~/.ssh
chmod 700 ~/.ssh
cp ${CDX_CONFIGS}/sftp/ssh/sftp_cdx_rsa* ~/.ssh
chmod 600 ~/.ssh/sftp_cdx_rsa
chmod 644 ~/.ssh/sftp_cdx_rsa.pub
touch ~/.ssh/config
cat ${CDX_CONFIGS}/sftp/ssh/config ~/.ssh/config > /tmp/.ssh-config; mv -f /tmp/.ssh-config ~/.ssh/config
chmod 600 ~/.ssh/config
cat ${CDX_CONFIGS}/sftp/ssh/known_hosts >> ~/.ssh/known_hosts
chmod 644 ~/.ssh/known_hosts
```

With this configuration, `sftp.local` will now connect to localhost, on port 2222, using the `sftp_cdx_rsa` IdentityFile,
without specifying `-i` or `-P` on the sftp command line.

##### Testing the server

Login to sftp:
```
cd $CDX_PROJECTS
sftp cdx@sftp.local
```

You should be prompted for the passphrase, which is `sftp123`,
and then see the `sftp> ` prompt.

Once connected to sftp, transfer a test file:
```
lpwd
lcd cdx-env-tools
lls -l
pwd
cd /nerp
put README.md
ls -l
lcd /tmp
get README.md
!ls -l /tmp
rm README.md
quit
```

Probe sftp from inside the container
```
cd $CDX_PROJECTS/cdx-env-tools/docker
docker-compose exec sftp bash
```

##### Stopping the server

Stop and remove the container
```
cd $CDX_PROJECTS/cdx-env-tools/docker
docker-compose rm -fsv sftp
```

##### TODOs:
##### Notes:
