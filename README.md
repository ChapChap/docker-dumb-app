# Dumb App AWS Deployment

## Infra creation

### Prereqs

- packages : jq, terraform
- local ssh key pair

### Creation

1) terraform init
2) terraform apply [auto-approve]

> Open ports are : 80, 8080, 22, 3000

## Appli deployment

### Bare VM

1) Prereqs installation on ec2 instance
   1) node7 repo  `curl -sL https://rpm.nodesource.com/setup_7.x | bash -`
   2) node7 package (! package manager aligned to AMI image used = yum)
      `sudo yum update && sudo yum install -y nodejs`
2) App Deposit - Push app file `scp app.js <ip>`
3) Launch App `node app.js &`

### Docker (Preferred)

1) Prereqs installation on ec2 instance
   - docker, git packages (! package manager aligned to AMI image used = yum)
2) Image building
   1) git clone repo
   2) docker build on ec2 instance
3) App deployment
   1) stop and suppr old container
   2) run new one
