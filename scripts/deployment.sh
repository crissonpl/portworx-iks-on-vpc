#!/bin/bash

echo "Mounting volume to example app"

# Current context
echo "Config path: $CONFIGPATH"
export KUBECONFIG=$CONFIGPATH
kubectl config current-context

echo 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: "'$DEPLOYMENT_LABEL-deployment'"
  labels:
    app: "'$DEPLOYMENT_LABEL'"
spec:
  replicas: 3
  selector:
    matchLabels:
      app: "'$DEPLOYMENT_LABEL-app'"
  template:
    metadata:
      labels:
        app: "'$DEPLOYMENT_LABEL-app'"
    spec:
      schedulerName: stork
      containers:
      - image: "'$IMAGE_NAME'"
        name: "'$DEPLOYMENT_LABEL-container'"
        volumeMounts:
        - name: "'$DEPLOYMENT_LABEL-volume'"
          mountPath: "'$FILE_PATH'"
      volumes:
      - name: "'$DEPLOYMENT_LABEL-volume'"
        persistentVolumeClaim:
          claimName: "'$PVC_NAME'"' > tmp.yaml

cat tmp.yaml

kubectl apply -f tmp.yaml

rm tmp.yaml

kubectl describe deployment $DEPLOYMENT_LABEL-deployment