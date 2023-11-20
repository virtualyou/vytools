# WireMock Setup

WireMock is used to mock backend services.
These notes show how to run WireMock as a Docker container.

## Run WireMock as a Docker container

This assumes that the mTLS keystores are available for your environment. See [README-PKI.md](README-PKI.md)
We also assume that ~/.curlrc is configured with the mTLS keystores. E.g.: `setup.sh --curl`

Run WireMock container (port 8643)
(`wminit.sh` initializes the WireMock data area (empty), plus the PKI files by copying them from $CDX_CONFIGS/pki.)
```
wminit.sh
docker-compose up -d wiremock
docker-compose logs --tail 100 -f wiremock  # use ^C to stop tailing the log
```

See [docker-compose.yaml](docker/docker-compose.yaml)

## Stub Mappings

To use WireMock an app needs to create a set of Stub Mappings.
Each stub defines a request that it can handled, and the response that it will produce.

For example, to define a "Hello world" text response for `GET /api/v1/hello`:
```
curl -X POST https://localhost:8643/__admin/mappings \
    -H "Content-Type: application/json" -d @- <<EOF
{
    "request": {
        "method": "GET",
        "url": "/api/v1/hello"
    },
    "response": {
        "status": 200,
        "body": "Hello world",
        "headers": {
            "Content-Type": "text/plain"
        }
    }
}
EOF
```

Test this newly created test stub:
```
curl -X GET https://localhost:8643/api/v1/hello
```

Persist the current mappings:
```
curl -X POST https://localhost:8643/__admin/mappings/save
```

When new stubs are saved in this way they are written into the mappings directory, (/tmp/wiremock/mappings).
Each stub is saved as a .json file with a filename that is derived from a combination of its URI and UUID.
For example, `/api/v1/hello` might be persisted as: `apiv1hello-737bec16-4aa9-4323-97d6-ba03d2c435cc.json`
Since stub mappings are loaded and organized internally by UUID,
these cryptically named files can be renamed to something more maintainable. Eg: `hello.json`

The dev-time stub mappings for a given CDX application are maintained in `src/test/resources/wiremock/mappings`.

## Load Stub Mappings for Multiple APIs

During development it's useful to load the stub mappings for a group of APIs all at once, (eg, the 4 SMARTS APIs),
rather than standing-up an instance of WireMock for each API, each running on a different port#.

In order for WireMock to see the set of .json files to be loaded, they simply need to be inside the mappings directory.
They can be arranged in any arbitrary directory structure.

For example, to assemble the files for sabrsgl apps:
```
wmreload.sh sabrsgl
```

This re-populates the WireMock data area, copying in from each of the specified API apps, and then tells WireMock to reset.
(The command argument is same specifier that is understood by `each.sh -p`, which can be a comma separated list.)

Test the newly (re)loaded stubs:
```
curl -i https://localhost:8643/sapi/v1/allocations/health
curl -i https://localhost:8643/sapi/v1/authorizations/health
```

## Admin API Summary

Common WireMock admin operations
```
curl -X POST   https://localhost:8643/__admin/mappings -H "Content-Type: application/json" -d '{}'
curl -X POST   https://localhost:8643/__admin/mappings/save
curl -X GET    https://localhost:8643/__admin/mappings
curl -X GET    https://localhost:8643/__admin/mappings/{id}
curl -X DELETE https://localhost:8643/__admin/mappings/{id}
curl -X DELETE https://localhost:8643/__admin/mappings         # wipes out stub mappings but NOT request log
curl -X POST   https://localhost:8643/__admin/reset            # wipes out stub mappings AND request log
curl -X POST   https://localhost:8643/__admin/requests/count
curl -X GET    https://localhost:8643/__admin/requests
```

## Docker Container Admin Snippets
```
docker-compose ps
docker-compose logs --tail 200 -f wiremock
docker-compose restart wiremock
docker-compose down
docker-compose rm -sf wiremock

docker-compose exec wiremock bash
ls -al mappings
```

## Trouble Shooting
###### Issue
The wiremock container fails to come up and we cannot see the logs.
###### Solution
Try bringing it up in the foreground, (omit the -d option), and the logs will appear interactively.
(This is analogous to docker run -i)
```
docker-compose up wiremock
```
The most common cause is that the PKI files cannot be found.
Check the volume pathing, which depends on some environment variables in
[docker-compose.yaml](https://bitbucket.org/navyfmp/cdx-env-tools/src/dev/docker/docker-compose.yaml)
