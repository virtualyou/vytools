#!/bin/bash
# encrypt PKI secrets for domain.yaml

env=dev

function _enc() {
    local pkiProp=$1
    local domainProp=$2
    local encd=$(encryptProperty.sh ${env} "${!pkiProp}" | tr -d '\r')
    printf "${domainProp}: %s%s%s\n" '![' "${encd}" ']'
}

source cdx-configs_/${env}/.pkirc

_enc CDX_KEYSTORE_PASS    https.keystore.password
_enc CDX_KEY_PASS         https.keystore.key.password
_enc CDX_TRUSTSTORE_PASS  https.truststore.password
