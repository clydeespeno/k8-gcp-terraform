#!/bin/bash

set -ex

query="$(jq -s '.')"

scriptsdir=$(dirname "$0")
WORKING_DIR=$(realpath "${scriptsdir}")

WORKERS_COUNT=$(echo $query | jq '.[0].workers|tonumber')
KUBERNETES_HOSTNAMES=$(echo $query | jq -r '.[0].kubernetes_hostnames')
KUBERNETES_PUBLIC_ADDRESS=$(echo $query | jq -r '.[0].kubernetes_public_address')
KUBERNETES_CLUSTER=$(echo $query | jq -r '.[0].cluster')

for i in $(seq 1 "$WORKERS_COUNT"); do
  idx=$(($i - 1))
  declare "WORKER_IP_$idx=$(echo $query | jq -r --arg idx $idx '.[0].workerips|split(",")|.[$idx|tonumber]')"
done

cd $WORKING_DIR/gen

[ ! -f "ca.pem" ] && ../generate-ca-certs.sh
[ ! -f "admin.pem" ] && ../generate-admin-certs.sh
[ ! -f "admin.kubeconfig" ] && ../generate-admin-config.sh "$KUBERNETES_CLUSTER"
[ ! -f "service-account.pem" ] && ../generate-service-account-certs.sh
[ ! -f "kube-controller-manager.pem" ] && ../generate-kube-controller-manager-certs.sh
[ ! -f "kube-controller-manager.kubeconfig" ] && ../generate-kube-controller-manager-config.sh "$KUBERNETES_CLUSTER"
[ ! -f "kube-proxy.pem" ] && ../generate-kube-proxy-certs.sh
[ ! -f "kube-proxy.kubeconfig" ] && ../generate-kube-proxy-config.sh "$KUBERNETES_PUBLIC_ADDRESS" "$KUBERNETES_CLUSTER"
[ ! -f "kube-scheduler.pem" ] && ../generate-kube-scheduler-certs.sh
[ ! -f "kube-scheduler.kubeconfig" ] && ../generate-kube-scheduler-config.sh "$KUBERNETES_CLUSTER"
[ ! -f "encryption-config.yaml" ] && ../generate-encryption-config.sh
[ ! -f "kubernetes.pem" ] && ../generate-kubernetes-certs.sh
for i in $(seq 1 "$WORKERS_COUNT"); do
  idx=$(($i - 1))
  WORKER_IP="WORKER_IP_$idx"
  instance=k8-worker-$idx
  if [ ! -f "k8-worker-${idx}.pem" ]; then
    ../generate-worker-certs.sh $instance ${!WORKER_IP}
  fi
  if [ ! -f "k8-worker-${idx}.kubeconfig" ]; then
    ../generate-worker-config.sh $instance "$KUBERNETES_PUBLIC_ADDRESS" "$KUBERNETES_CLUSTER"
  fi
done

mkdir -p controller

cp ca*.pem controller/.
cp admin*.pem controller/.
cp admin.kubeconfig controller/.
cp service-account*.pem controller/.
cp kube-controller-manager*.pem controller/.
cp kube-controller-manager.kubeconfig controller/.
cp kube-scheduler*.pem controller/.
cp kube-scheduler.kubeconfig controller/.
cp encryption-config.yaml controller/.
cp kubernetes*.pem controller/.

for i in $(seq 1 "$WORKERS_COUNT"); do
  idx=$(($i - 1))
  worker=k8-worker-$idx
  mkdir -p $worker
  cp ca.pem $worker/.
  cp "$worker.pem" $worker/.
  cp "$worker-key.pem" $worker/.
  cp "$worker.kubeconfig" $worker/.
done

function workersIps() {
  resultIp='{}'
  for i in $(seq 1 "$WORKERS_COUNT"); do
    idx=$(($i - 1))
    WORKER_IP="WORKER_IP_$idx"
    resultIp=$(jq \
      --arg index "worker-ip-$idx" \
      --arg ip ${!WORKER_IP} '.[$index]=$ip' <<< "$resultIp")
  done
  echo "$resultIp"
}

workersIps |
  jq --arg hostnames $KUBERNETES_HOSTNAMES '.hostnames=$hostnames' |
  jq --arg cluster $KUBERNETES_CLUSTER '.cluster=$cluster'
