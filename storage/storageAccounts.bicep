param projectName string
param environment string
param location string = resourceGroup().location
@allowed([ 'FileStorage', 'StorageV2' ])
param kind string = 'StorageV2'
@allowed([ 'Cool', 'Hot' ])
param accessTier string = 'Hot'
@allowed([ 'Premium_LRS', 'Premium_ZRS', 'Standard_GRS', 'Standard_GZRS', 'Standard_LRS', 'Standard_RAGRS', 'Standard_RAGZRS', 'Standard_ZRS' ])
param skuName string = 'Standard_LRS'
param allowBlobPublicAccess bool = false
param allowSharedKeyAccess bool = false
param isHnsEnabled bool = false
param supportsHttpsTrafficOnly bool = true
param defaultToOAuthAuthentication bool = true
param minimumTlsVersion string = 'TLS1_2'
param blobServicesContainers array = []
@allowed([ 'Allow', 'Deny' ])
param networkAclDefaultAction string = 'Deny'
@allowed([ 'AzureServices', 'Logging', 'Metrics', 'None' ])
param networkAclBypass string = 'AzureServices'
param advancedThreatProtectionEnabled bool = false

var uniqueValue = take(uniqueString(resourceGroup().id), 5)
var storageAccountName = toLower('st${projectName}${environment}${uniqueValue}')

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  kind: kind
  sku: {
    name: skuName
  }
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    isHnsEnabled: isHnsEnabled
    minimumTlsVersion: minimumTlsVersion
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    networkAcls: {
      defaultAction: networkAclDefaultAction
      bypass: networkAclBypass
    }
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' existing = {
  name: 'default'
  parent: storageAccount
}

resource containers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = [for container in blobServicesContainers: {
  name: toLower(container)
  parent: blobServices
  properties: {}
}]

resource advancedThreatProtection 'Microsoft.Security/advancedThreatProtectionSettings@2019-01-01' = if (advancedThreatProtectionEnabled) {
  name: 'current'
  scope: storageAccount
  properties: {
    isEnabled: true
  }
}

output storageAccountName string = storageAccount.name
output storageAccountResourceId string = storageAccount.id
output storageAccountBlobUrl string = kind == 'StorageV2' && isHnsEnabled != true ? storageAccount.properties.primaryEndpoints.blob : ''
output storageAccountDfsUrl string = kind == 'StorageV2' && isHnsEnabled == true ? storageAccount.properties.primaryEndpoints.dfs : ''
