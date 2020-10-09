#!/bin/bash

echo "Removing $SECRET_NAME from $NAMESPACE default service account image pull secrets"

# Current context
echo "Config path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

COUNT=$(kubectl get serviceaccount default -n $NAMESPACE -o json | jq '.imagePullSecrets | length')
echo "Found $COUNT image pull secrets"

if [ $COUNT -eq 0 ]; then
    echo "No secrets to delete, skipping"
else 
  INDEX=$(kubectl get serviceaccount default -n $NAMESPACE -o json | jq '.imagePullSecrets | map(.name == "'$SECRET_NAME'") | index(true)')

  if [ "$INDEX" == "" ] || [ "$INDEX" == "null" ]; then 
    echo "No secret to delete, skipping"
  else
    kubectl patch -n $NAMESPACE serviceaccount/default --type='json' -p='[{"op": "remove","path": "/imagePullSecrets/'$INDEX'"}]'
  fi
fi