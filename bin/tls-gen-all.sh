#!/bin/bash
# (Re)generate PKI file sets for each environment,
# and establish the various inter-operating mTLS trust relationships
# Example:
#   tls-gen-all.sh |tee tls-gen-all.out

tls-gen-env.sh dev
tls-gen-env.sh qa
tls-gen-env.sh qa2
tls-gen-env.sh local
