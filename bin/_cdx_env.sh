# set env-specific URL vars, drawing from cdx-configs
#   CDX_URI & WIREMOCK_URI

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

cdxEnv=${1:-local}
shift 1

CDX_CONFIGS_TMP=/tmp/cdx-configs_${cdxEnv}

${BASH_DIR}/pull-env-configs.sh ${cdxEnv} $(dirname ${CDX_CONFIGS_TMP})

# read cdx-config properties

# source .pkirc
if [[ -z ${_pkirc} ]]; then
    _pkirc=${CDX_CONFIGS_TMP}/.pkirc
    source ${_pkirc}
fi

# source domain.yaml
if [[ -z ${domain_yaml} ]]; then
    domain_yaml=${CDX_CONFIGS_TMP}/domain.yaml
    source ${BASH_DIR}/_functions_yaml.sh
    source_yaml domain_ ${domain_yaml}
fi

# --------------------------------------------------

export CDX_URI=https://${CDX_HOST}:${domain_https_port:-443}
export WIREMOCK_URI=https://${WIREMOCK_HOST}
