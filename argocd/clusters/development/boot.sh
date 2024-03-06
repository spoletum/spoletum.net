#!/bin/bash

# Install the CSI Driver
helm upgrade --install csi-driver hcloud/hcloud-csi -n kube-system

# Install the LetsEncrypt Issuer
kubectl apply -n cert-manager -f letsencrypt.yml

# Install ArgoCD
kubectl create namespace argocd
helm upgrade --install argocd argo/argo-cd -n argocd -f argocd-values.yml
