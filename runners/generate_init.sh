#!/bin/bash

set -ex

query="$(jq -s '.')"

KUBERNETES_PUBLIC_ADDRESS=$(echo $query | jq -r '.[0].kubernetes_public_address')
KUBERNETES_CLUSTER=$(echo $query | jq -r '.[0].cluster')

scriptsdir=$(dirname "$0")
WORKING_DIR=$(realpath "${scriptsdir}")
PROJECT_ROOT=$(realpath "$WORKING_DIR/..")
CONFIG_GEN_DIR="${PROJECT_ROOT}/config/gen"

mkdir -p ${WORKING_DIR}/gen
rm -rf ${WORKING_DIR}/gen/*

cat >> ${WORKING_DIR}/gen/init-kubectl.sh <<EOF
#!/bin/bash
set -x

kubectl config set-cluster ${KUBERNETES_CLUSTER} \\
  --certificate-authority=${CONFIG_GEN_DIR}/ca.pem \\
  --embed-certs=true \\
  --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

kubectl config set-credentials admin \\
  --client-certificate=${CONFIG_GEN_DIR}/admin.pem \\
  --client-key=${CONFIG_GEN_DIR}/admin-key.pem

kubectl config set-context ${KUBERNETES_CLUSTER} \\
  --cluster=${KUBERNETES_CLUSTER} \\
  --user=admin

kubectl config use-context ${KUBERNETES_CLUSTER}
EOF

cat >> $WORKING_DIR/gen/add-dns.sh <<EOF
#!/bin/bash
set -x
kubectl apply -f ${WORKING_DIR}/coredns.yaml
kubectl get pods -l k8s-app=kube-dns -n kube-system
EOF

cat >> $WORKING_DIR/gen/verify.sh <<EOF
#!/bin/bash
set -x
kubectl run --generator=run-pod/v1 busybox --image=busybox:1.28 --command -- sleep 3600
kubectl get pods -l k8s-app=kube-dns -n kube-system

POD_NAME=\$(kubectl get pods -l run=busybox -o jsonpath="{.items[0].metadata.name}")
kubectl exec -ti \$POD_NAME -- nslookup kubernetes
EOF

cat >> $WORKING_DIR/gen/data-enc.sh <<EOF
#!/bin/bash
set -x

kubectl create secret generic ${KUBERNETES_CLUSTER} \
  --from-literal="mykey=mydata"

gcloud compute ssh k8-controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/config/ca.pem \
  --cert=/config/kubernetes.pem \
  --key=/config/kubernetes-key.pem\
  /registry/secrets/default/${KUBERNETES_CLUSTER} | hexdump -C"
EOF

cat >> $WORKING_DIR/gen/nginx.sh <<EOF
#!/bin/bash
set -x

kubectl create deployment nginx --image=nginx
kubectl get pods -l app=nginx
EOF

cat >> $WORKING_DIR/gen/port-forwad.sh <<EOF
#!/bin/bash
set -x

POD_NAME=\$(kubectl get pods -l app=nginx -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward \$POD_NAME 8080:80
EOF

chmod -R +x $WORKING_DIR/gen

echo '{}' |
  jq --arg script ${WORKING_DIR}/gen/init-kubectl.sh '._1_init=$script' |
  jq --arg script ${WORKING_DIR}/gen/add-dns.sh '._2_addDns=$script' |
  jq --arg script ${WORKING_DIR}/gen/verify.sh '._3_verify=$script' |
  jq --arg script ${WORKING_DIR}/gen/data-enc.sh '._4_enc=$script' |
  jq --arg script ${WORKING_DIR}/gen/nginx.sh '._5_nginx=$script' |
  jq --arg script ${WORKING_DIR}/gen/port-forwad.sh '._6_portForward=$script'
