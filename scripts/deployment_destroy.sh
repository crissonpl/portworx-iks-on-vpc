#!/bin/bash

echo "Destroying deployment $DEPLOYMENT_LABEL-deployment"

# Current context
echo "Config path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

RUNNING=$(kubectl get pods -l app=$DEPLOYMENT_LABEL-app -o json | jq '.items | length')
DESIRED=0

echo "Scaling deployment to 0"
kubectl scale deployment/$DEPLOYMENT_LABEL-deployment --replicas=$DESIRED

############################################
# Wait for deployment to scale to 0 
############################################
LIMIT=20
SLEEP_TIME=30
i=0

while [ $i -lt $LIMIT ] && [ $DESIRED -ne $RUNNING ]; do 
    RUNNING=$(kubectl get pods -l app=$DEPLOYMENT_LABEL-app -o json | jq '.items | length')

    if [ $DESIRED -eq $RUNNING ]; then 
        echo "(Attempt $i of $LIMIT) $DEPLOYMENT_LABEL pods: Desired $DESIRED, Running $RUNNING"
    else 
        echo "(Attempt $i of $LIMIT) $DEPLOYMENT_LABEL pods: Desired $DESIRED, Running $RUNNING, sleeping $SLEEP_TIME"
        sleep $SLEEP_TIME
    fi 

    i=$(( $i + 1 ))
done

if [ $i -eq $LIMIT ] && [ $DESIRED -ne $RUNNING ]; then 
    echo "Exhausted max attempts ($i/$LIMIT) waiting for $DEPLOYMENT_LABEL-deployment to scale down to $DESIRED ($RUNNING running), force deleting"
    for p in $(kubectl get pods -l app=$DEPLOYMENT_LABEL-app | grep Terminating | awk '{print $1}')
    do 
        echo "Deleting $p"
        kubectl delete pod $p --grace-period=0 --force
    done

    sleep 10 # wait for the deletes to finish
    RUNNING=$(kubectl get pods -l app=$DEPLOYMENT_LABEL-app -o json | jq '.items | length')
    echo "$DEPLOYMENT_LABEL pods: Desired $DESIRED, Running $RUNNING"
fi

kubectl delete deployment $DEPLOYMENT_LABEL-deployment