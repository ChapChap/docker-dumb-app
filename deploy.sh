#!/usr/bin/env bash -e
# AIO Deployment JS App
# - Deploy AWS Infra (ec2)
# - Build image
# - Deploy App

#################
# Infra
#################

if [[ -z "${AWS_ACCESS_KEY_ID}" ]];then
  echo "Enter AWS credentials"
  echo -n "AWS_ACCESS_KEY_ID : "
  read AWS_ACCESS_KEY_ID
  echo -n "AWS_SECRET_ACCESS_KEY : "
  read -s AWS_SECRET_ACCESS_KEY
fi

# Packages
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

echo -n "Infra check/creation ... "
terraform init &> /dev/null
if ! terraform plan &> /dev/null;then
  terraform apply -auto-approve
fi
echo "OK"

echo -n "VM Config ... "
INSTANCE_NAME=$(jq -r .outputs.instance_public_dns.value terraform.tfstate)
SSH_CONNECTION="ssh -i \"ssh_key\" -o \"StrictHostKeyChecking no\" \"ec2-user@${INSTANCE_NAME}\""

bash -c "${SSH_CONNECTION} sudo yum install -y docker git > /dev/null"
bash -c "${SSH_CONNECTION} sudo /etc/init.d/docker start > /dev/null"
echo "OK"
#################

#################
# Build Image
#################

GIT_REPO="https://github.com/ChapChap/docker-dumb-app.git"
GIT_DEFAULT_BRANCH="master"
APP_DIR="/var/opt/dumb-app/"
IMG_NAME="dumb-app"

echo -n "Enter branch name to pull (default: master) : "
read GIT_BRANCH
GIT_BRANCH=${GIT_BRANCH:-$GIT_DEFAULT_BRANCH}

echo -n "Building Image... "
bash -c "${SSH_CONNECTION} sudo rm -rf ${APP_DIR} > /dev/null"
bash -c "${SSH_CONNECTION} sudo git clone ${GIT_REPO} ${APP_DIR} -b ${GIT_BRANCH} &> /dev/null"
bash -c "${SSH_CONNECTION} sudo docker build -t ${IMG_NAME} ${APP_DIR} > /dev/null"
echo "OK"

#################

#################
# Deploy App
#################

APP_NAME="dumb-app"
PORT="3000"

echo -n "Deploying App... "
bash -c "${SSH_CONNECTION} sudo docker stop ${APP_NAME} &> /dev/null"
bash -c "${SSH_CONNECTION} sudo docker rm ${APP_NAME} &> /dev/null"
bash -c "${SSH_CONNECTION} sudo docker run -dit --name=${APP_NAME} --restart=always -p ${PORT}:8080 ${IMG_NAME} > /dev/null"
echo "OK"
echo
echo "Go to http://${INSTANCE_NAME}:${PORT}"

#################