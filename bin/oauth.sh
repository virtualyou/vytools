#!/bin/bash
################################################################################
# WARNING: USE AT YOUR OWN RISK, WORK IN PROGRESS, REVIEW BEFORE YOU RUN.
#
# Copyright (c) 2023 VirtualYou
# License: https://github.com/virtualyou/vytools/blob/main/LICENSE
#
# oauth.sh
#
# Obtain an OAuth token, then execute the given curl command along with Authorization header.
# The token is not reused, a new token is obtained each time.
# Assumes jq is available on the PATH.

# ignore command customizations, if any
unalias curl 2> /dev/null
unalias cut  2> /dev/null
unalias jq   2> /dev/null

# cred defaults (expression evaluation via : no-op command) - to override, do export in your .vyrc
: ${OAUTH_CLIENT:=admin}
: ${OAUTH_SECRET:=oauthAdmin123}

# initialized in vytools/vyrc, can be customized in your .vyrc
#if [[ -z "${OAUTH_CLIENT}" || -z "${OAUTH_SECRET}" ]]; then
#    echo "Required variable(s) OAUTH_CLIENT and/or OAUTH_SECRET not set." >&2
#    exit 1
#fi

# parse BASE_URL from curl args
for arg in "$@"; do
    if [[ "${arg}" =~ ^http.* ]]; then
        BASE_URL=$(cut -d/ -f1-3 <<<"${arg}")
    fi
done
if [[ -z "${BASE_URL}" ]]; then
    echo "Missing URL argument." >&2
    exit 1
fi

_oauth_authorize() {
    ( set -xe
      curl -sf -X POST "${BASE_URL}/oauth/authorize" \
        -H "Content-Type: application/json" \
        -d "{ \"client_id\": \"${OAUTH_CLIENT}\", \"client_secret\": \"${OAUTH_SECRET}\" }"
    )
}

OAUTH_TOKEN=$(_oauth_authorize | jq -r .access_token)
( set -x
  curl "$@" -H "Authorization: bearer ${OAUTH_TOKEN}"
)
