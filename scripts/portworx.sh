#!/bin/bash

# Current context
echo "Config path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

DESIRED=$(kubectl get ds/portworx -n kube-system -o json | jq .status.desiredNumberScheduled)
RUNNING=0

LIMIT=20
SLEEP_TIME=30
i=0

while [ $i -lt $LIMIT ] && [ $DESIRED -ne $RUNNING ]; do 
    RUNNING=$(kubectl get pods -n kube-system -l name=portworx --field-selector status.phase=Running -o json | jq '.items | length') 

    if [ $DESIRED -eq $RUNNING ]; then 
        echo "(Attempt $i of $LIMIT) Portworx pods: Desired $DESIRED, Running $RUNNING"
    else 
        echo "(Attempt $i of $LIMIT) Portworx pods: Desired $DESIRED, Running $RUNNING, sleeping $SLEEP_TIME"
        sleep $SLEEP_TIME
    fi 

    i=$(( $i + 1 ))
done
