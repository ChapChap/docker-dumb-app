# Dumb App AWS Deployment

## Infra creation

### Prereqs

- packages : jq, terraform
- local ssh key pair

### Creation

1) terraform init
2) terraform apply [auto-approve]

### Connection

1) retreive instance name/ip
2) ssh check

## Appli deployment

### Docker

1) Prereqs installation on ec2 instance
   1) docker package (! package manager aligned to AMI image used = yum)
2) Image building
   1) Push app & Dockerfile
