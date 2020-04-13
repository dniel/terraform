# Terraform
This repo contains my Terraform scripts that deployes all Kubernetes manifests to my k8s clusters.

## Kubernetes deployment
The terraform scripts does NOT contain the provisioning of Kubernetes itself. I have two clusters 
running, one in Amazon EKS deployed by cloudformation and one on-prem on VMWare deployed with 
Canonical JUJU.

## Init manifests
Some stuff I havent managed yet to deploy with Terraform and will ned to be deployed to Kubernetes
manually with `kubectl` before running Terraform. The directory `init` contains manifests for k8s
and should be deployed using `kubectl create -f init/` before running `terraform apply`. 

## Environments
I run several deployments at the same time, both on-prem in parallel and in Amazon EKS.
Under the directory `envs` there is one directory for each deployment.
- cloud is deployed to Amazon.
- home is my primary deployment on-prem.
- home-demo is a stack also deployed on-prem, just to make sure its possible to deploy
  multiple stacks in parallel on the same K8s cluster to run multiple versions of the same stack.

## Modules
Under modules I have put all my re-usable code, the environments should not contain much code itself
but should instead use the modules to configure deploy the software.