#!/bin/bash
################################################################################
if [[ "$1" == "--help" ]]; then
    cat <<'ENDHELP'
Pull down individual logs from a k8s Mule pod.

First navigate to the desired target directory,
then run the script with the desired log name as the argument.

Example:
  cd dev-logs
  k8smulelog.sh mule_ee.log
ENDHELP
    exit
fi
################################################################################

logFile=${1}
shift 1

mulepod=$(kubectl get pod | grep mulesoft | awk '{print $1}')
if [ "${logFile}" == "" ]; then
    echo "Make sure you are in the preferred local directory to copy logs!"
    echo "Please add in the desired log name from the list provided below."
    echo ""
    echo "Available logs to copy to a local directory:"
    ( set -x; kubectl exec -it ${mulepod} -- ls /opt/mule-enterprise-standalone-4.3.0/logs; )
    echo ""
    echo "Usage:"
    echo "k8smulelog <log name>"
else
    ( set -x; kubectl cp ${mulepod}:../logs/${logFile} ${logFile}; )
fi
