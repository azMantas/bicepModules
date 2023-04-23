param principalIds array

@allowed([ 'User', 'ServicePrincipal', 'Group' ])
param principalType string
param roledefinition string
param storageAccountName string

resource targetResource 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = [for principal in principalIds: {
  name: guid(principal, roledefinition, targetResource.id)
  scope: targetResource
  properties: {
    roleDefinitionId: roledefinition
    principalId: principal
    principalType: principalType
  }
}]
