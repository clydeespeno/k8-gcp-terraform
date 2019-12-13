#!/bin/bash

set -ex

query="$(jq -s '.')"

CONTROLLER_COUNT=$(echo $query | jq '.[0].controller_count|tonumber')
SSH_USER=$(echo $query | jq -r '.[0].ssh_user')
GCLOUD_ACCOUNT=$(echo $query | jq -r '.[0].gcloud_account')
PROJECT=$(echo $query | jq -r '.[0].project')
ZONE=$(echo $query | jq -r '.[0].zone')
SSH_KEY_FILE=$(echo $query | jq -r '.[0].ssh_key_file')

scriptsdir=$(dirname "$0")
WORKING_DIR=$(realpath "${scriptsdir}")
PROJECT_ROOT=$(realpath "$WORKING_DIR/..")
CONFIG_GEN_DIR="${PROJECT_ROOT}/config/gen"

mkdir -p ${WORKING_DIR}/gen
rm -rf ${WORKING_DIR}/gen/*

gen_script=${WORKING_DIR}/gen/init.sh

cat >> $gen_script <<EOF
#!/bin/bash
set -ex

EOF

for i in $(seq 1 "$CONTROLLER_COUNT"); do
  idx=$(($i - 1))
  instance="k8-controller-$idx"
  cat >> $gen_script <<EOF
gcloud compute scp \\
  $PROJECT_ROOT/scripts/controller/init.sh \\
  $PROJECT_ROOT/scripts/controller/bootstrap/ \\
  $PROJECT_ROOT/scripts/controller/config/ \\
  $PROJECT_ROOT/config/gen/controller \\
  $SSH_USER@${instance}:. \\
  --account ${GCLOUD_ACCOUNT} \\
  --project ${PROJECT} \\
  --zone ${ZONE} \\
  --ssh-key-file=${SSH_KEY_FILE} \\
  --recurse

EOF
done

for i in $(seq 1 "$CONTROLLER_COUNT"); do
  idx=$(($i - 1))
  instance="k8-controller-$idx"
  cat >> $gen_script <<EOF
echo 'set -ex
sudo chmod +x init.sh
sudo ./init.sh
exit
' | gcloud compute ssh \\
  --account ${GCLOUD_ACCOUNT} \\
  --project ${PROJECT} \\
  --zone ${ZONE} \\
  --ssh-key-file=${SSH_KEY_FILE} \\
  ${SSH_USER}@${instance}

EOF
done


chmod -R +x ${WORKING_DIR}/gen

echo '{}' | jq --arg script $gen_script '.script=$script'
