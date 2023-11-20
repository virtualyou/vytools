#!/bin/bash
# Pull a specific branch of cdx-configs to cdx-configs_<branch-name>
# A separate single-branch working directory is used for each branch for isolation and efficiency

branchName=${1:-local}
tmpRoot=${2:-/tmp}

workingDir=cdx-configs_${branchName}

pullFreshnessThreshold=90  # seconds

# TODO: query this list from git, branches directly off of master
validEnvs=( local dev qa )
if [[ ! $(IFS=:; echo ":${validEnvs[*]}:") =~ :${branchName}: ]]; then
    echo "Unrecognized cdx-configs environment branch: ${branchName}" >&2
fi

# seconds since last git pull
pullFreshness() {
    local lastPullTime
    if [[ "$(uname -s)" == 'Darwin'* ]]; then
        lastPullTime=$(stat -f '%m' .git/FETCH_HEAD) 2> /dev/null  # Mac
    else
        lastPullTime=$(stat -c '%Y' .git/FETCH_HEAD) 2> /dev/null  # unix
    fi
    echo $(( $(date +'%s') - lastPullTime ))
}

( set -e
  cd ${tmpRoot}
  if [[ -d ${workingDir} ]]; then
      cd ${workingDir}
      if (( $(pullFreshness) > pullFreshnessThreshold )); then
          ( set -x
            git pull
          )
      fi
  else
      ( set -x
        git clone -b ${branchName} --single-branch https://bitbucket.org/navyfmp/cdx-configs.git ${workingDir}
      )
  fi
)
