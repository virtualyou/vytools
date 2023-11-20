#!/bin/bash
# (Re)generate PKI file sets for an environment,
# and establish the various inter-operating mTLS trust relationships
# Examples:
#   tls-gen-env.sh dev
#   tls-gen-env.sh qa
#   tls-gen-env.sh local

# This script assumes that all 3 of the cdx-configs branches are pulled locally
# under cdx-configs_/

# TODO: for local, for the extra dev & qa trust relationships in support of client tools (curl, Postman),
#       establish a separate trust store "local_cacerts", rather than lumping that into cdx_cacerts

env=${1:-local}

# add inter-environment trusts
add_env_trust() {
    local trustee=${1}
    # criss-crossing cdx-envA <-> wiremock-envB
    #                        cert to trust                as alias         add to <dest>_cacerts
    tls_util.sh trust  ../${trustee}/pki/cdx.cer            cdx-${trustee}      wiremock
    tls_util.sh trust  ../${trustee}/pki/wiremock.cer  wiremock-${trustee}        cdx
}

# add cdx-cdx trusts (for access via client tools - curl, Postman, etc)
add_cdx_cdx_trust() {
    #                     cert to trust      as alias    add to <dest>_cacerts
    tls_util.sh trust ../local/pki/cdx.cer   cdx-local           cdx
    tls_util.sh trust ../dev/pki/cdx.cer     cdx-dev             cdx
    tls_util.sh trust ../qa/pki/cdx.cer      cdx-qa              cdx
    tls_util.sh trust ../qa2/pki/cdx.cer     cdx-qa2             cdx
}

( set -e
  cd ${CDX_PROJECTS}/cdx-configs_/${env}

  # Generate mTLS-paired certificates, (cdx & wiremock), ie, trust established between them

  tls_util.sh gen

  # establish additional trust among various environments
  if [[ "${env}" == local ]]; then
      # LOCAL trusts DEV & QA
      add_env_trust dev
      add_env_trust qa
      add_env_trust qa2

      # cdx-local trusts cdx-*
      add_cdx_cdx_trust
  elif [[ "${env}" == dev || "${env}" == qa || "${env}" == qa2 ]]; then
      # each env trusts LOCAL 
      add_env_trust local
  else
      echo "No additional trust relationships for environment: ${env}"
  fi
)
