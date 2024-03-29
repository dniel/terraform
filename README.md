![Publish Docker Image](https://github.com/dniel/terraform/workflows/Publish%20Docker%20Image/badge.svg)

# Terraform
This repo contains my Terraform scripts that deployes all Kubernetes manifests to my k8s clusters.
Providers used to deploy manifests to Kubernetes.
- [Official Kubernetes provider for k8s resources.](https://www.terraform.io/docs/providers/kubernetes/index.html)
- [Alpha Kubernetes provider for generic k8s manifests.](https://github.com/hashicorp/terraform-provider-kubernetes-alpha)
- [Auth0 provider to create clients and resource servers.](https://www.terraform.io/docs/providers/auth0/index.html)
- [Community Helm Provider for deploying Helm charts.](https://www.terraform.io/docs/providers/helm/index.html)
- [Official AWS provider to handle Route53 registration of applications.](https://www.terraform.io/docs/providers/aws/index.html)

## Kubernetes deployment
The terraform scripts does NOT contain the provisioning of Kubernetes itself. I have two clusters 
running, one in Amazon EKS deployed by cloudformation and one on-prem on VMWare deployed with Tanzu Kubernetes Grid (TKG).

## Environments
I run several deployments at the same time, both on-prem in parallel and in Amazon EKS.
Under the directory `envs` there is one directory for each deployment.

The different development environments for software development.
- prod is deployed to Amazon.
- stage is deployed to Amazon.
- test is deployed to on-prem on VMWare Tanzu.
- dev is deployed to on-prem  on VMWare Tanzu.

In addition
- services is a shared services on-prem on VMWare Tanzu.
  
To deploy an environment its meant to stand in its directory and do `terraform apply`
Secrets are stored in encrypted files in the repo and contains a couple of variables 
that are needed to run the terraform scripts.

## Templates
Two different default templates to configure an environment with.

### template
Is a small and mostly empty base template. It contains common stuff like
a default configuration of traefik and forwardauth and not much more.

### template-services
Is a more specialized template that contains some applications that are
meant to be installed just once for each cluster and contains tools for
cross-cutting concerns like logging and observability implemented with 
prometheus, grafana, loki and more.

## Modules
Under modules I have put all my re-usable code, the environments should not contain much code itself
but should instead use the modules to configure deploy the software.
