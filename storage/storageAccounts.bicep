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
param minimumTlsVersion string = 'TLS1_2'

var uniqueValue = take(uniqueString(resourceGroup().id), 5)
var storageAccountName = toLower('st${projectName}${environment}${uniqueValue}')

resource storageaccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
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
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

output storageAccountName string = storageaccount.name
output storageAccountResourceId string = storageaccount.id
