#!/usr/bin/env bash
################################################################################
# entrypoint script for docker container
################################################################################

kubeconfig='kubeconfig'
environment=$1

################################################################################
# Help
################################################################################
Help() {
  # Display Help
  echo "Run Terraform apply."
  echo "  help          - display this message."
  echo "  <environment> - apply terraform for env."
  echo "Syntax: entrypoint.sh <environment>"
  echo
}

################################################################################
# Retrieve Kubeconfig from AWS Secretsmanager
################################################################################
Kubeconf(){
  echo "Get kubeconf from secretsmanager secret '$1'.."
  mkdir ~/.kube;
  aws secretsmanager get-secret-value --secret-id kubeconfig | jq --raw-output '.SecretString' > ~/.kube/config;
  ls -la ~/.kube/config
}

################################################################################
# Apply                                                                        #
################################################################################
Apply() {
  echo "Apply Terraform on environment '$1'.."
  cd envs/$1 || exit
  ls -la
  terraform init -input=false
  terraform apply -target module.template.module.traefik -auto-approve
  terraform apply -auto-approve
}

if [ "$environment" != "" ]; then
  Kubeconf $kubeconfig
  Apply $environment
else
  Help
fi

