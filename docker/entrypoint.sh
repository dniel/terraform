#!/usr/bin/env bash

################################################################################
# Help                                                                         #
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
  echo "Get kubeconf.."
  mkdir ~/.kube;
  aws secretsmanager get-secret-value --secret-id kubeconfig | jq --raw-output '.SecretString' > ~/.kube/config;
  ls -la ~/.kube/config
}

################################################################################
# Apply                                                                         #
################################################################################
Apply() {
  echo "Apply Terraform $1.."
  cd envs/$1 || exit
  ls -la
  terraform init -input=false
  terraform apply -auto-approve
}

if [ "$1" != "" ]; then
  Kubeconf
  Apply $1
else
  Help
fi

