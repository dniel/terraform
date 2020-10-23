#!/usr/bin/env bash

################################################################################
# Help                                                                         #
################################################################################
Help() {
  # Display Help
  echo "Run Terraform apply."
  echo "Syntax: entrypoint.sh <environment>"
  echo
}

################################################################################
# Retrieve Kubeconfig from AWS Secretsmanager
################################################################################
Kubeconf(){
  echo "Get kubeconf.."
  mkdir ~/.kube;
  aws secretsmanager get-secret-value --secret-id kubeconfig | jq --raw-output '.SecretString' > ~/.kube/config;
}

################################################################################
# Apply                                                                         #
################################################################################
Apply() {
  echo "Apply Terraform.."
  cd envs/$1 || exit
  ls -la
  terraform init -input=false
  terraform apply -auto-approve
}

if [ "$1" != "" ]; then
  Kubeconf
  Apply
else
  Help
fi

