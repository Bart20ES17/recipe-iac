
param location string = resourceGroup().location
param appServiceAppName string
param appServicePlanName string
param dbhost string
param dbuser string
param dbpass string
param dbname string
param runtimeStack string
param startupCommand string

var appServicePlanSkuName = 'B1'

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: appServicePlanSkuName
  }
  kind: 'linux'
}
resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
name: appServiceAppName
location: location
properties: {
  serverFarmId: appServicePlan.id
  httpsOnly: true
  siteConfig: {
    linuxFxVersion: runtimeStack
    appCommandLine: startupCommand
    appSettings: [
      {
        name: 'DBUSER'
        value: dbuser
      }
      {
        name: 'DBPASS'
        value: dbpass
      }
      {
        name: 'DBNAME'
        value: dbname
      }
      {
        name: 'DBHOST'
        value: dbhost
      }
      {
        name: 'SCM_DO_BUILD_DURING_DEPLOYMENT'
        value: 'true'
      }
      {
        name: 'ENABLE_ORYX_BUILD'
        value: 'true'
      }
    ]
  }
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
