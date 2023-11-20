#!/bin/bash

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  cd cdx-configs
  tls_util.sh gen|trust <args>
Examples (assuming parallel checkouts under cdx-configs_):
  cd cdx-configs_/dev
  tls_util.sh gen
  cd cdx-configs_/local
  tls_util.sh trust ../dev/pki/cdx.cer cdx-dev wiremock

See tls-gen-all.sh

gen   Generate mTLS-paired certificates, one for cdx, one for wiremock.
      The key & keystore passwords are taken from .pkirc.
      The truststore produced for each will be populated with the public key of the other,
      and the resulting keystore & truststore are exported as .pem files.
      The files are generate into sub-directory: ./pki
trust <cert-alias> <filename>.cer
      Add a certificate to truststore: pki/cdx-<env>_cacerts.jks,
      and re-export to cdx-<env>_cacerts.pem

Assumptions:
  Executed in cdx-configs that is checked out to the intended env branch
  .cdxrc has been source'd
ENDHELP
    exit
fi
################################################################################

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

case ${1} in
      gen) op=gen ;;
    trust) op=trust; shift 1; providedCertFile=${1} certAlias=${2} tsKind=${3} ;;
        *) echo "Unrecognized operation: ${1}" >&2; exit 1 ;;
esac

# --------------------------------------------------

# this should be defined in .cdxrc, which is sourced by .bashrc or .zshrc
[[ -z ${CDX_CONFIGS} ]] && { echo "Cannot continue, CDX_CONFIGS is not defined." >&2; exit 1; }

source ${CDX_PROJECTS}/cdx-env-tools/bin/tls_func.sh

( set -e
  source .pkirc
  [[ -z ${CDX_ENV} ]] && { echo "Cannot continue, CDX_ENV is not defined. Check the .pkirc" >&2; exit 1; }

  case ${op} in
        gen) gen_cert_pair ;;
      trust) add_cert_to ${providedCertFile} ${certAlias} ${tsKind} ;;
  esac
)
