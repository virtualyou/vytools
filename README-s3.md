# S3 Server #
The NERP APIs access an S3 server on the CFMS side.
This README outlines how to standup an S3 service locally for daily development activities.

Dependencies:

- Docker
- AWS CLI client

On Windows there are two options for using Docker:

- Install Docker Desktop for Windows, (which also installs Hyper-V).
- Install Docker into a hypervisor of your choice, (eg, VirtualBox).

## Run S3 as a Docker container

Create the local storage directory area:
```
setup.sh --storage
mkdir -p ${CDX_STORAGE}/s3/cfms
```

Run via Docker Compose
```
cd ${CDX_PROJECTS}/cdx-env-tools/docker
docker-compose up -d s3
docker-compose logs --tail 100 -f s3
```

http://localhost:9000

Probe s3 from inside the container
```
cd $CDX_PROJECTS/cdx-env-tools/docker
docker-compose exec s3 bash
```

## Install AWS CLI

https://aws.amazon.com/cli/

Configure AWS CLI:
```
aws configure set default.s3.signature_version s3v4
aws configure
```

When prompted, answer as follows:

    AWS Access Key ID [****************Y2M5]: cfms
    AWS Secret Access Key [****************CMMH]: cfms1234
    Default region name [None]:
    Default output format [None]:

Add the following alias to your .bashrc:
```
alias s3="aws --endpoint-url http://localhost:9000 s3"
```

##### Using the service

Create a bucket:
```
s3 mb s3://cfms
s3 ls
ls -l ${CDX_STORAGE}/s3
```

Copy a file into the bucket:
```
s3 cp .cdxrc s3://cfms
s3 ls s3://cfms
ls -l ${CDX_STORAGE}/s3/cfms
```

Other commands:
```
s3 rm s3://cfms/.cdxrc
s3 rb s3://cfms
```

##### Stopping the server

Stop and remove the container
```
cd $CDX_PROJECTS/cdx-env-tools/docker
docker-compose rm -fsv s3
```

##### TODOs:
##### Notes:
##### Trouble Shooting:

Miscellaneous diagnostic commands:
```
cat ~/.aws/config
cat ~/.aws/credentials
aws configure list
aws sts get-caller-identity
```

