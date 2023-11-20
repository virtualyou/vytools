# Active MQ #
ActiveMQ is the messaging server that implements JMS queuing for the CDX environment.
This README outlines how to install ActiveMQ locally for daily development activities.

#### Download and Setup #####
Official download page: https://activemq.apache.org/components/classic/download/

#### Run natively (Windows example)

Unzip into `C:\apps\apache-activemq-5.15.12`
Startup:
    "C:\apps\apache-activemq-5.15.12\bin\activemq.bat" start

##### Running ActiveMQ using Docker Compose
```
cd ${CDX_PROJECTS}/cdx-env-tools
docker-compose up -d activemq
```

This will execute the Apache ActiveMQ server in a docker container for your local testing.
No other configuration is necessary.

#### Access Admin Console

http://localhost:8161/admin
Upon first time access, you will create the admin account.
The following steps assume `admin`/`admin`.

#### REST API usage
List queues
```
curl -f -u admin:admin "http://localhost:8161/admin/xml/queues.jsp"
```

##### Publish an item to a queue `test`
REST Interface: https://activemq.apache.org/components/artemis/documentation/1.0.0/rest.html

Publish an item to the queue. The queue is auto-created.
```
curl -f -X POST "http://admin:admin@localhost:8161/api/message?destination=queue://test" \
  -d body="Hello World"
```
Consume the item off the queue.
```
curl -f -X GET "http://admin:admin@localhost:8161/api/message?destination=queue://test" \
  --cookie-jar /tmp/cookies --cookie /tmp/cookies \
  --max-time .2
```

You should see "Hello World"

##### ActiveMQ Console

In the ActiveMQ console, http://localhost:8161/admin, you can browse the content of queues.
For example, from the main page:

    Queues
        advana/audit-intake/1.0
            ID:LATHE-55569-1588602517166-1:1:1:1:2

You can click into a queued item to view the message details, including payload content.
