targetScope = 'subscription'

param projectName string = 'storage'
param environment string = 'tst'
param location string = 'westeurope'

// ---------------- simple storage account ----------------------

resource storageResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'storage-${projectName}-${environment}'
  location: location
}

module simpleStorage 'storageAccounts.bicep' = {
  scope: storageResourceGroup
  name: 'simple-storage-account'
  params: {
    projectName: projectName
    environment: environment
  }
}

output simpleStorageAccountName string = simpleStorage.outputs.storageAccountName
output SimpleStorageAccountUrl string = simpleStorage.outputs.storageAccountBlobUrl

// ---------------- config storage account ----------------------


module configParams 'storageAccounts.bicep' = {
  scope: storageResourceGroup
  name: 'config-storage-account'
  params: {
    projectName: 'datalake'
    environment: environment
    isHnsEnabled: true
    blobServicesContainers: [
      'PDF'
      'Incoming'
    ]
    advancedThreatProtectionEnabled: true
  }
}

output storageAccountName string = configParams.outputs.storageAccountName
output storageAccountUrl string = configParams.outputs.storageAccountDfsUrl

// ---------------- assign RBAC roles ----------------------


module assignMultipleRoles 'roleAssignments-roleDefinitions.bicep' = {
  scope: storageResourceGroup
  name: 'rbac-multiple-roles'
  params: {
    principalId: 'e34ed234-5c06-4449-ad5a-c86b227adb21'
    principalType: 'Group'
    roledefinitions: [
      '/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
      '/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    ]
    storageAccountName: configParams.outputs.storageAccountName
  }
}

// ---------------- create multiple storage account ----------------------


var multipleStorageAccounts = [
  'Olivia'
  'William'
  'Sophia'
  'James'
  'Isabella'
  'Ethan'
  'Mia'
  'Alexander'
  'Ava'
  'Michael'
  'Emily'
  'Daniel'
  'Grace'
  'Benjamin'
  'Charlotte'
]

module multipleStorageAccount 'storageAccounts.bicep' = [for name in multipleStorageAccounts: {
  name: 'multiple-${name}'
  scope: storageResourceGroup
  params:{
    projectName: name
    environment: environment
  }
}]

// -----------  create a resource group for each storage account  ------------------

var dedicatedResourceGroup = [
  'Sophie'
  'Jacob'
  'Avery'
]

resource indexResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = [for (name, index) in dedicatedResourceGroup: {
  name: 'storage-${name}-${environment}'
  location: location
}]

module indexstorage 'storageAccounts.bicep' = [for (name, index) in dedicatedResourceGroup: {
  name: 'multiple-${name}'
  scope: indexResourceGroup[index]
  params:{
    projectName: name
    environment: environment
  }
}]

