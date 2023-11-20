# kubectl #
The kubectl client is how we access the Kubernetes environments.

See https://twenty8.atlassian.net/wiki/spaces/NAV/pages/559251742/Kubernetes+Dashboard+Access

## Command Snippets

```
# verify installation
kubectl version --client

# install krew: https://github.com/kubernetes-sigs/krew/releases
krew.exe install krew

PATH+=%USERPROFILE%\.krew\bin
kubectl krew list

# install OIDC plugin
kubectl krew install oidc-login
kubectl krew search | grep oidc

kubectl oidc-login setup \
  --oidc-issuer-url=https://keycloak.kube.navy.ms3-inc.com/auth/realms/master \
  --oidc-client-id=kubernetes \
  --oidc-client-secret=<vpn-user-password>

# Kubernetes dashboard: https://dashboard.kube.navy.ms3-inc.com/
cat ~/.kube/cache/oidc-login/*

# set DEV namespace
kubectl config set-context --current --namespace=dev

# pod listing
kubectl get pods

# cli
kubectl exec -it redis-master-0 -- redis-cli -a 8pOqN2YiRA

# mule runtime
kubectl exec -it mulesoft-430-666856bbb8-h6lvm -- /bin/bash
```

##### TODOs:
##### Notes:
