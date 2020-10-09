#!/bin/bash

echo "Updating $NAMESPACE default service account image pull secrets"

# Current context
echo "Config path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

COUNT=$(kubectl get serviceaccount default -n $NAMESPACE -o json | jq '.imagePullSecrets | length')
echo "Found $COUNT image pull secrets"

if [ $COUNT -eq 0 ]; then
  kubectl patch -n $NAMESPACE serviceaccount/default -p='{"imagePullSecrets": [{"name": "'$SECRET_NAME'"}]}'
else
  SECRET=$(kubectl get serviceaccount default -n $NAMESPACE -o json | jq '.imagePullSecrets[] | select(.name == "'$SECRET_NAME'")')

  if [ "$SECRET" == "" ]; then 
    kubectl patch -n $NAMESPACE serviceaccount/default --type='json' -p='[{"op": "add", "path": "/imagePullSecrets/-", "value": {"name": "'$SECRET_NAME'"}}]'
  else 
    echo "Secret already added: $SECRET"
  fi
fi