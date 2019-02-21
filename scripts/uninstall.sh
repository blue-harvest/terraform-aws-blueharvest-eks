#!/bin/sh

helm init --client-only

kubectl delete -f ./helm/istio/istio-1.0.4/templates/crds.yaml -n istio-system

helm del --purge istio
helm del --purge nginx-ingress
helm del --purge nginx-ingress-internal
helm del --purge external-dns-intranet
helm del --purge external-dns-internet
helm del --purge external-dns-nginx
helm del --purge cert-manager
helm del --purge kubernetes-dashboard
helm del --purge metrics-server
helm del --purge cluster-autoscaler
helm del --purge curator
helm del --purge fluentd
helm del --purge cerebro

kubectl delete sts -l app=elasticsearch --namespace logging
kubectl delete sts -l app=grafana --namespace monitoring
kubectl delete sts -l app=prometheus --namespace monitoring

sleep 60

kubectl delete pvc -l app=elasticsearch --namespace logging

sleep 180