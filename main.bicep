param nameseed string = 'kubeflow'
param location string = resourceGroup().location
param signedinuser string

//---------Kubernetes Construction---------
module aksconst './AKS-Construction/bicep/main.bicep' = {
  name: 'aksconstruction'
  params: {
    location: location
    resourceName: nameseed
    enable_aad: false
    enableAzureRBAC: false
    registries_sku: ''
    omsagent: false
    retentionInDays: 30
    agentCount: 2
    agentVMSize: 'Standard_D2ds_v4'
    osDiskType: 'Managed'
    AksPaidSkuForSLA: false
    networkPolicy: 'azure'
    azurepolicy: ''
    acrPushRolePrincipalId: signedinuser
    adminPrincipalId: signedinuser
    AksDisableLocalAccounts: false
    custom_vnet: false
    upgradeChannel: 'stable'

    //Workload Identity requires OidcIssuer to be configured on AKS
    // oidcIssuer: true

    //We'll also enable the CSI driver for Key Vault
    keyVaultAksCSI: true
  }
}
output aksOidcIssuerUrl string = aksconst.outputs.aksOidcIssuerUrl
output aksClusterName string = aksconst.outputs.aksClusterName

// deploy keyvault
// module keyVault './AKS-Construction/bicep/keyvault.bicep' = {
//   name: 'kv${nameseed}'
//   params: {
//     resourceName: 'app${nameseed}'
//     keyVaultPurgeProtection: false
//     keyVaultSoftDelete: false
//     location: location
//     privateLinks: false
//   }
// }
// output kvAppName string = keyVault.outputs.keyVaultName

resource kubeflowidentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: 'kubeflow'
  location: location

  // resource fedCreds 'federatedIdentityCredentials' = {
  //   name: nameseed
  //   properties: {
  //     audiences: aksconst.outputs.aksOidcFedIdentityProperties.audiences
  //     issuer: aksconst.outputs.aksOidcFedIdentityProperties.issuer
  //     subject: 'system:serviceaccount:superapp:serversa'
  //   }
  // }
}
output kubeflowidentityClientId string = kubeflowidentity.properties.clientId
output kubeflowidentityId string = kubeflowidentity.id

// module kvSuperappRbac './KVRBAC.bicep' = {
//   name: 'kubeflowKvRbac'
//   params: {
//     appclientId: kubeflowidentity.properties.principalId
//     kvName: keyVault.outputs.keyVaultName
//   }
// }
