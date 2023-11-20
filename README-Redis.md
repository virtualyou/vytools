# Redis #
Redis is the in-memory key-value store that serves as the cache broker for CDX.
This README outlines how to standup an ADVANA-specific instance of Redis locally
for daily development activities.

Dependencies:
- Docker
- telnet or netcat, (optional) for ad hoc Redis access

On Windows there are two options for using Docker:
- Install Docker Desktop for Windows, (which also installs Hyper-V).
- Install Docker into a hypervisor of your choice, (eg, VirtualBox).


## Run Redis as a Docker container

Run via Docker Compose
```
cd ${CDX_PROJECTS}/cdx-env-tools/docker
docker-compose up -d redis
```

This will execute the Redis server in a docker container for your local testing.
No other configuration is necessary.

##### Testing the server

Ping Redis from the command line
```
(echo "auth redis123"; echo ping; sleep 3) | telnet localhost 6379
(echo "auth redis123"; echo "keys *"; sleep 3) | telnet localhost 6379
```

Probe Redis from inside the container
```
cd ${CDX_PROJECTS}/cdx-env-tools/docker
docker-compose exec redis bash
redis-server --version
redis-cli -a redis123 ping
redis-benchmark -q -n 1000 -c 10 -P 5
^D
```

##### Stopping the server

Stop and remove the container
```
cd ${CDX_PROJECTS}/cdx-env-tools/docker
docker-compose rm -fsv redis
```

##### TODOs:
##### Notes:
