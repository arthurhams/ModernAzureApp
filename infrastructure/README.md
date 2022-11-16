# Resource Group

```
az group create --name ModernAzureApp --location westeurope --tags Purpose=Demo Production=NO

```

# Deploy

```
az deployment group create --confirm-with-what-if --resource-group ModernAzureApp --template-file main.bicep #  --parameters param.json

```
