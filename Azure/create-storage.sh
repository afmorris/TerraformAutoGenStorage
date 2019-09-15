#!/bin/sh

# Heads up! You need to define the following environment variables:
# RESOURCE_GROUP_NAME for the resource group that will contain the Azure Storage Account that will house your Terraform state files
# STORAGE_ACCOUNT_NAME for the name of the Azure Storage Account
# KEYVAULT_NAME to store the Storage Account's access key, so you don't have to manually keep track of it
# LOCATION for the location of the Azure resources
# KEYVAULT_SECRET_NAME for the name of the secret in Key VAult of the Storage Account's access key
# CONTAINER_NAME for the Azure Blob Storage's container that will hold the Terraform state file(s)

RESOURCE_GROUP_NAME=mm-terraform-rg
STORAGE_ACCOUNT_NAME=mmterraform
KEYVAULT_NAME=mm-terraform-kv

# Create resource group
az group create --name ${RESOURCE_GROUP_NAME} --location ${LOCATION}

# Create storage account
az storage account create --resource-group ${RESOURCE_GROUP_NAME} --name ${STORAGE_ACCOUNT_NAME} --sku Standard_LRS --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group ${RESOURCE_GROUP_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --query [0].value -o tsv)

# Create Key Vault
az keyvault create --name ${KEYVAULT_NAME} --resource-group ${RESOURCE_GROUP_NAME} --location ${LOCATION}

# Store account key in secret
az keyvault secret set --name ${KEYVAULT_SECRET_NAME} --vault-name ${KEYVAULT_NAME} --value $ACCOUNT_KEY

# Create blob container
az storage container create --name ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --account-key $ACCOUNT_KEY
