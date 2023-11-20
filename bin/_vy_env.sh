# set env-specific URL vars, drawing from vy-configs
#   VY_URI & WIREMOCK_URI

BASH_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

vyEnv=${1:-local}
shift 1

VY_CONFIGS_TMP=/tmp/vy-configs_${vyEnv}

${BASH_DIR}/pull-env-configs.sh ${vyEnv} $(dirname ${VY_CONFIGS_TMP})

# read vy-config properties

# source .pkirc
if [[ -z ${_pkirc} ]]; then
    _pkirc=${VY_CONFIGS_TMP}/.pkirc
    source ${_pkirc}
fi

# source domain.yaml
if [[ -z ${domain_yaml} ]]; then
    domain_yaml=${VY_CONFIGS_TMP}/domain.yaml
    source ${BASH_DIR}/_functions_yaml.sh
    source_yaml domain_ ${domain_yaml}
fi

# --------------------------------------------------

export VY_URI=https://${VY_HOST}:${domain_https_port:-443}
export WIREMOCK_URI=https://${WIREMOCK_HOST}
