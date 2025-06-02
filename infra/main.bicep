param environmentName string
param location string
param resourceGroupName string
param AZURE_STORAGE_CONNECTION_STRING string

output RESOURCE_GROUP_ID string = resourceGroup().id

resource appService 'Microsoft.Web/sites@2021-02-01' = {
  name: '${uniqueString(subscription().id, resourceGroup().id, environmentName)}-appservice'
  location: location
  tags: {
    'azd-service-name': 'ImageResizeWebApp'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${uniqueString(subscription().id, resourceGroup().id, environmentName)}-identity': {}
    }
  }
  properties: {
    serverFarmId: '${uniqueString(subscription().id, resourceGroup().id, environmentName)}-appservice-plan'
    siteConfig: {
      cors: {
        allowedOrigins: ['*']
      }
    }
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: '${environmentName}storage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource appInsights 'Microsoft.Insights/components@2021-02-01' = {
  name: '${environmentName}-appinsights'
  location: location
  properties: {
    Application_Type: 'web'
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-02-01' = {
  name: '${environmentName}-loganalytics'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-02-01' = {
  name: '${environmentName}-keyvault'
  location: location
  properties: {
    sku: {
      family: 'A',
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: []
  }
}
