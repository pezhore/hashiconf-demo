#!/bin/bash

# Remove the docker_env file if it exists
[ -e docker_env ] && rm docker_env

# These are the environment vars we want to pull into Docker
env_vars=("VAULT_TOKEN" "VAULT_ADDR" "VAULT_SKIP_VERIFY" "VSPHERE_SERVER" "VSPHERE_PASSWORD" "VSPHERE_USER")

echo "ANSIBLE_HOST_KEY_CHECKING=False" >> docker_env

# Loop through the vars and add them to the docker_env file
for var in ${env_vars[@]}; do
    echo "$var=${!var}" >> docker_env
done