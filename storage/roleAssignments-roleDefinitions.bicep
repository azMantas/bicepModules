param principalId string
@allowed([ 'User', 'ServicePrincipal', 'Group' ])
param principalType string
param roledefinitions array
param storageAccountName string

resource targetResource 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName
}

resource rbac 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = [for role in roledefinitions: {
  name: guid(principalId, role, targetResource.id)
  scope: targetResource
  properties: {
    roleDefinitionId: role
    principalId: principalId
    principalType: principalType
  }
}]
