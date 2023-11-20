# SSL Setup

CDX operates on a principle of "All SSL all the time".
This refers to

- "Front-door" connections, originating from API consumers into CDX APIs.
- "Back-door" connections, that CDX makes to back-end system, (CFMS, Treasury, etc).
- "Internal" connections, that CDX makes to its internal sub-systems, (Redis, ActiveMQ, etc).

Most of these connections use one-way TLS in which only the server presents a PKI certificate.
(An everyday example of this is connecting to your online bank.)

But for connections that use two-way "Mutual TLS",
both the server and the client must present their certificate to other, ("paired certificates").
This will be the case for most "back-door" connections that we will implement,
and is the primary focus of this README.

In production, in order for CDX to connect with another systems using mTLS,
we will need to acquire their certificate, (ie, their public-key),
and we will need to provide them with ours.
This to-be-determined key-exchange process typically involves
file sharing between system administrators, and/or Certificate Authority identification.

Note that a single CDX certificate will support both one-way and two-way TLS connections.
In other words it acts as the server certificate for front-door connections,
and as the client certificate for back-door connections.

The nature and structure of PKI certificates is out of scope for this discussion.

## Development and Test Environments

For our DEV and QA environments, we use WireMock to stand-in for live sub-systems.
The following steps generate mTLS-paired certificates, one for CDX, and one for WireMock.
It also creates corresponding .pem files required by utility tools, like curl and Postman.

These steps only need to be done one-time per deployment environment, (local, dev, qa, etc).
So if `cdx-configs/pki` for a given environment already contains files,
then we would only need to repeat these steps if, say, a password needs to be changed.

Note that individual workstations can reuse the PKI files provided
in the '[local](https://bitbucket.org/navyfmp/cdx-configs/src/local/pki/)' branch of cdx-configs.

### Generate Certificate Pair

First setup the required host names and secrets in `cdx-configs/.pkirc`.
The host names need to be exactly as they will appear in https URLs.

Note that for the WireMock cert, the key and keystore passwords need to be the same,
because that is the default configuration of its embedded Jetty server.

Delete and re-generate the `pki/` directory. Example:
```
cd cdx-configs
tls-gen-env.sh dev

git add pki
git commit -m "add PKI files"
```

[tls-gen-all.sh](bin/tls-gen-all.sh)

#### Curl Usage

An example using a made-up URL:
```
curl -i "https://localhost:8643/api/v1/test1" \
    --cacert ${CDX_CONFIGS}/pki/cdx_cacerts.pem \
    --cert ${CDX_CONFIGS}/pki/cdx_keystore.pem:cdxKeyStore123
```

(Once you have done `setup.sh --curl` on your workstation, which populates .curlrc, the curl cert options become unnecessary.)

#### Postman Configuration

```
Settings > Settings
    Certificates
        CA Certificates: ON
        PEM file: cdx_cacerts.pem
        Add Certificate
            Host:       https://localhost:8643
            CRT file:   cdx_keystore.pem
            KEY file:   cdx_keystore.pem
            Passphrase: cdxKeyStore123
```

### Further Explanation of PKI Generation

The steps that `tls_util.sh gen` performs are:

Enable mTLS connectivity from CDX to WireMock

1. Generate the CDX certificate (`cdx.cer` & `cdx_keystore.jks`)
2. Generate the WireMock certificate (`wiremock.cer` & `wiremock_keystore.jks`)
3. Put the CDX public-key into the WireMock trust-store (`wiremock_cacerts.jks`)
4. Put the WireMock public-key into the CDX trust-store (`cdx_cacerts.jks`)

Enable mTLS connectivity to CDX and WireMock for utilities (curl, Postman, etc)

1. Create .pem files of CDX keystore & CDX trust-store (`cdx_keystore.pem` & `cdx_cacerts.pem`)

(The name `cacerts` is a tradition "trust store" file name where a list of trusted Certificate Authorities (CAs) is maintained.)

### PKI Usage

PKI certificate configuration for the various subsystems and tools:

|          | Client Cert to send             | Server Certs to trust          | Where configured                          |
| -------- | ------------------------------- | ------------------------------ | ----------------------------------------- |
| Mule     | cdx_keystore.jks                | cdx_cacerts.jks                | `<tls:context` in mule-domain-config.xml  |
| curl     | --cert cdx_keystore.pem         | --cacert cdx_cacerts.pem       | ~/.curlrc                                 |
| Postman  | Client certs: cdx_keystore.pem  | CA Certs: cdx_cacerts.pem      | Settings > Certificates                   |
| browsers | Personal cert: cdx_keystore.p12 | Trusted certs: cdx_cacerts.p12 | Settings > Security > Manage Certificates |

For Mule, see also [cdx-configs/domain.yaml](https://bitbucket.org/navyfmp/cdx-configs/src/dev/domain.yaml)
```
https.keystore.path:   ${cdx_configs}/pki/cdx_keystore.jks
https.truststore.path: ${cdx_configs}/pki/cdx_cacerts.jks
```

For curl, see your ~/.curlrc

To run WireMock, see [cdx-env-tools/docker/docker-compose.yaml](https://bitbucket.org/navyfmp/cdx-env-tools/src/dev/docker/docker-compose.yaml)
```
--https-keystore   pki/wiremock_keystore.jks
--https-truststore pki/wiremock_cacerts.jks
```

### Adding other Trusted Certificates

In order to connect to other environments via mTLS, (eg, connecting to 'dev' or 'qa' from a local workstation),
we add those public-key(s) to our local trust-store.

An example using hypothetical file path:
```
cd cdx-configs
tls_util.sh add wiremock-dev ../wiremock-dev.cer
```

This adds a certificate to `pki/cdx_cacerts.jks`, and then re-exports to `pki/cdx_cacerts.pem`.

A .pem is a text file. Have a look at it before and after.

### Managing certificates in the popular web browsers

Windows
  Chrome and Internet Explorer use the same underlying certificate manager interface.
  Firefox is similar, but organized slightly differently.

  Getting to the certificate manager:
    IE : (Tools) > Internet options > Content > [Certificates]
    Chrome : (Customize) > Settings > Security > Manage Certificates
    Firefox : (menu) > Options > Privacy & Security > [View Certificates...]

Import the CDX certificate into the Certificate manager:

    Personal
        [Import...] cdx-configs/pki/cdx_keystore.p12 (local)
        Password: cdxKeyStore123

Mac
  In Keychain
    System/My Certificates: client certs
    System/Certificates:    trust-store certs

For the Dashboard web app,
import the Wiremock certificate into the browser as well, in order to access the Monitoring wiremocks.
