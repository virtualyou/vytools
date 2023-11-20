#!/bin/bash
# For the given CDX environment,
# add the CFMS CA (GoDaddy G2) to the trust store (cdx_cacerts), and re-export to .p12 & .pem
# Examples:
#   tls-add-trust-cfms.sh local
#   tls-add-trust-cfms.sh dev
#   tls-add-trust-cfms.sh qa

env=${1:-local}

( set -e
  cd ${CDX_PROJECTS}/cdx-configs_/${env}
  source .pkirc

  source ${CDX_PROJECTS}/cdx-env-tools/bin/tls_func.sh

  cd pki
  # add gdroot-g2 to cdx_cacerts.jks
  add_public_key gdroot-g2 ${CDX_PROJECTS}/cdx-configs_/cfms-pki/gdroot-g2.crt cdx_cacerts.jks ${CDX_TRUSTSTORE_PASS}

  # re-export .p12 & .pem
  export_pem cdx-${CDX_ENV} cdx_cacerts ${CDX_TRUSTSTORE_PASS}
)
