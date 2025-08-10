#!/bin/bash

echo "Applying PersistentVolume..."
kubectl apply -f .infrastructure/pv.yml

echo "Applying PersistentVolumeClaim..."
kubectl apply -f .infrastructure/pvc.yml

echo "Applying Secret..."
kubectl apply -f .infrastructure/secret.yml

echo "Applying ConfigMap..."
kubectl apply -f .infrastructure/configMap.yml

echo "Applying Deployment..."
kubectl apply -f .infrastructure/deployment.yml

echo "Deployment completed"
