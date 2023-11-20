
# --------------------------------------------------
# helper functions

_keytool() ( set -x; keytool "$@" -v -noprompt; )
_openssl() ( set -x; openssl "$@"; )

# --------------------------------------------------
# helper functions

# Generate a certificate (.cer) & export to keystore (_keystore.jks)
gen_cert() (
    local aliasName=$1
    local dname=$2
    local keystoreFile=$3
    local keyPass="$4"
    local keystorePass="$5"

    set -e

    # Create keystore containing public and private keys
    #   .jks
    _keytool -genkeypair -alias ${aliasName} -keyalg ${CERT_KEY_ALG} -keysize ${CERT_KEY_SIZE} -validity ${CERT_DURATION} \
        -keypass "${keyPass}" -storepass "${keystorePass}" -keystore ${keystoreFile}_keystore.jks \
        -dname "${dname}"

    # Export the certificate (public key)
    #   .jks -> .cer
    _keytool -exportcert -alias ${aliasName} \
        -keystore ${keystoreFile}_keystore.jks -storepass "${keystorePass}" \
        -file ${keystoreFile}.cer
)

# Add a public key, (from provided .cer), into trust store (.jks)
# Eg: add_public_key cfms-prod ../../cfms_certs/prod/p739w001.cfms.navy.mil.cer  cdx_cacerts.jks cdxTrustStore123
add_public_key() (
    local aliasName=$1
    local certFile=$2
    local truststoreFile=$3
    local truststorePass="$4"
    set -e

    [[ "$(uname -s)" == 'CYGWIN'* ]] && certFile=$(cygpath -w ${certFile})

    if [[ -e ${truststoreFile} ]]; then
        # delete any previous entry
        ( set +e;
          _keytool -delete -alias ${aliasName} -keystore ${truststoreFile} -storepass "${truststorePass}" \
          > /dev/null
          : # reset exit code
        )
    fi

    _keytool -importcert -trustcacerts \
        -file ${certFile} -alias ${aliasName} \
        -keystore ${truststoreFile} -storepass "${truststorePass}"
)

# Create a .pem & .p12 files from a .jks
# TBD: when keyPass differs from keystorePass
export_pem() (
    local aliasName=$1
    local keystoreFile=$2
    local keystorePass="$3"
    local keyPass="$4"
    ( set -e
      # Import keystore as a PKCS#12
      if [[ ! -z "${keyPass}" ]]; then
          # for a keystore
          _keytool -importkeystore \
              -srckeystore  ${keystoreFile}.jks -srcstorepass  "${keystorePass}" -srcalias  ${aliasName} -srckeypass  "${keyPass}" \
              -destkeystore ${keystoreFile}.p12 -deststorepass "${keystorePass}" -destalias ${aliasName} -destkeypass "${keyPass}" -deststoretype PKCS12
      else
          # for a truststore
          _keytool -importkeystore \
              -srckeystore  ${keystoreFile}.jks -srcstorepass  "${keystorePass}" \
              -destkeystore ${keystoreFile}.p12 -deststorepass "${keystorePass}" -deststoretype PKCS12
      fi

      # Export public key to .pem (includes encrypted private key)
      _openssl pkcs12 \
          -in  ${keystoreFile}.p12 -passin  pass:"${keystorePass}" \
          -out ${keystoreFile}.pem -passout pass:"${keystorePass}"

      # Export private key to .key (unencrypted)
      #_openssl pkcs12 -nocerts -nodes \
      #    -in  ${keystoreFile}.p12 -passin  pass:"${keystorePass}" \
      #    -out ${keystoreFile}.key
      # Export public key to .crt
      #_openssl pkcs12 -nokeys \
      #    -in  ${keystoreFile}.p12 -passin  pass:"${keystorePass}" \
      #    -out ${keystoreFile}.crt
    )
    #rm -f ${keystoreFile}.p12
)

# --------------------------------------------------
# main functions

# generate new certs
gen_cert_pair() (
    set -e
    ( set -x
      rm -rf pki
      mkdir pki
    )

    ( cd pki

      # NOTE - For the WireMock cert, the key and keystore passwords need to be the same,
      # because that's determined by its embedded Jetty? server config

      echo "=================================================="
      echo "Generating certs & keystores for: ${CDX_ENV}"

      # generate certs & keystores
      # CN= needs to match the host name that will appear in the https URLs
      gen_cert cdx-${CDX_ENV}      "CN=${CDX_HOST},OU=CDX,OU=${CDX_ENV}"           cdx      "${CDX_KEY_PASS}" "${CDX_KEYSTORE_PASS}"
      gen_cert wiremock-${CDX_ENV} "CN=${WIREMOCK_HOST},OU=WireMock,OU=${CDX_ENV}" wiremock "${WM_KEY_PASS}"  "${WM_KEYSTORE_PASS}"

      echo "=================================================="
      echo "Populating truststores: ${CDX_ENV}"

      # populate truststores
      add_public_key cdx-${CDX_ENV}      cdx.cer      wiremock_cacerts.jks "${WM_TRUSTSTORE_PASS}"
      add_public_key wiremock-${CDX_ENV} wiremock.cer cdx_cacerts.jks      "${CDX_TRUSTSTORE_PASS}"

      echo "=================================================="
      echo "Creating .pem files: ${CDX_ENV}"

      echo "--------------------------------------------------"
      # create pem files for use by client tools (curl, Postman)
      export_pem cdx-${CDX_ENV} cdx_keystore "${CDX_KEYSTORE_PASS}"   "${CDX_KEY_PASS}"
      export_pem cdx-${CDX_ENV} cdx_cacerts  "${CDX_TRUSTSTORE_PASS}"

      echo "--------------------------------------------------"
      # we don't need pem files for wiremock, because we don't access CDX from a WireMock server
      # but we produce them any way, because they're a valuable whitebox record of the keystores
      export_pem wiremock-${CDX_ENV} wiremock_keystore "${WM_KEYSTORE_PASS}"   "${WM_KEY_PASS}"
      export_pem wiremock-${CDX_ENV} wiremock_cacerts  "${WM_TRUSTSTORE_PASS}"
    )
)

# derive absolute file path
abs_path() {
    echo "$(cd "$(dirname "${1}")"; pwd)/$(basename "${1}")"
}

# add the public key from the given .cer to the specified truststore
add_cert_to() (
    local certFile=$1
    local aliasName=$2
    local destTS=$3
    set -e
    if [[ ! -e ${certFile} ]]; then
        echo "File not found: ${certFile}" >&2
        return 1
    fi
    local certFilepath=$(abs_path ${certFile})
    local truststorePass
    case ${destTS} in
             cdx) truststorePass="${CDX_TRUSTSTORE_PASS}" ;;
        wiremock) truststorePass="${WM_TRUSTSTORE_PASS}" ;;
    esac
    cd pki
    add_public_key ${aliasName} ${certFilepath} ${destTS}_cacerts.jks "${truststorePass}"
    export_pem ${destTS}-${CDX_ENV} ${destTS}_cacerts "${truststorePass}"
)

# export .p12 as .jks
# assumes that the .p12 has no passwords set
# Examples:
#   p12_to_jks p739a0013-t cdxKeyStore123 cdxKey123
#   p12_to_jks p739a0013-t cdxTrustStore123
p12_to_jks() (
    keystoreFile="${1}"
    keystorePass="${2}"
    keyPass="${3}"
    set -x
    if [[ ! -z "${keyPass}" ]]; then
        # for a keystore
        _keytool -importkeystore \
          -srckeystore  ${keystoreFile}.p12 -srcstoretype pkcs12 -srcstorepass  "" \
          -destkeystore ${keystoreFile}.jks -deststoretype jks   -deststorepass "${keystorePass}" -destkeypass "${keyPass}"
    else
        # for a truststore
        _keytool -importkeystore \
          -srckeystore  ${keystoreFile}.p12 -srcstoretype pkcs12 -srcstorepass  "${keystorePass}" \
          -destkeystore ${keystoreFile}.jks -deststoretype jks   -deststorepass "${keystorePass}"
    fi
)

# export private key (eg, for use by nginx)
# Examples:
#   export_private_key cdx      cdxKeyStore123
#   export_private_key wiremock wmKeyStore123
export_private_key() {
    keystoreFilePfx="${1}"
    keystorePass="${2}"
    openssl pkcs12 -in ${keystoreFilePfx}_keystore.p12 -passin "pass:${keystorePass}" \
      -out ${keystoreFilePfx}_private.key -nodes -nocerts
}
