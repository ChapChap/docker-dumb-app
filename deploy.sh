#!/usr/bin/env bash -e

if ! which jq &> /dev/null;then
  echo "Please install the package jq";
  exit 1
fi

if ! which terraform &> /dev/null;then
  echo "Please install the package terraform";
  exit 1
fi

if [[ ! -f ssh_key ]];then
  ssh-keygen -t rsa -b 4096 -N "" -f ssh_key
fi

terraform init
terraform apply -auto-approve

INSTANCE_NAME=$(jq -r .outputs.instance_public_dns.value terraform.tfstate)
SSH_CONNECTION="ssh -i \"ssh_key\" -o \"StrictHostKeyChecking no\" \"ec2-user@${INSTANCE_NAME}\""
bash -c "${SSH_CONNECTION} hostname;whoami"
bash -c "${SSH_CONNECTION} sudo yum install -y docker"
