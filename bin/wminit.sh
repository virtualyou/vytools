#!/bin/bash

################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Usage:
  wminit.sh

Initialize the WireMock data area ($WMROOT) from scratch, including the PKI files copied from cdx-configs ($CDX_CONFIGS/pki).
ENDHELP
    exit
fi
################################################################################

# ignore any command customizations
unalias cp    2> /dev/null
unalias rm    2> /dev/null
unalias mkdir 2> /dev/null

# these should be defined in .vyrc, which is sourced by .bashrc or .zshrc
[[ -z ${WMROOT} ]]      && { echo "Cannot continue, WMROOT is not defined."      >&2; exit 1; }
[[ -z ${CDX_CONFIGS} ]] && { echo "Cannot continue, CDX_CONFIGS is not defined." >&2; exit 1; }

( set -ex
  rm -rf ${WMROOT}
  mkdir -p ${WMROOT}/mappings

  # populate mTLS keystore files
  mkdir -p ${WMROOT}/pki
  cp ${CDX_CONFIGS}/pki/wiremock* ${WMROOT}/pki
)
