#!/bin/bash
if ! minikube status | grep -q "apiserver: Running"; then
    echo "$(date): apiserver down, restarting minikube" >> ~/minikube-watchdog.log
    minikube start >> ~/minikube-watchdog.log 2>&1
fi
