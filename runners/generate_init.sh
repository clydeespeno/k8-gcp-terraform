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

gen_script=${WORKING_DIR}/gen/init-kubectl.sh

cat >> $gen_script <<EOF
#!/bin/bash
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

echo '{}' | jq --arg script $gen_script '.script=$script'
