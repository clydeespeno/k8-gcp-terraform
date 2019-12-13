#!/bin/bash

cat > kube-scheduler.yaml <<EOF
apiVersion: kubescheduler.config.k8s.io/v1alpha1
kind: KubeSchedulerConfiguration
clientConnection:
  kubeconfig: "/config/kube-scheduler.kubeconfig"
leaderElection:
  leaderElect: true
EOF
