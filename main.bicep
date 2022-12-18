@sys.description('The Web App name.')

param prod_service_backend string = 'brzycki-assignment-backend-prod'
@sys.description('The Web App name.')

param prod_service_frontend string = 'brzycki-assignment-frontend-prod'
@sys.description('The App Service Plan name.')

param prod_service string = 'brzycki-assignment-prod'
@sys.description('The Web App name.')

param dev_service_backend string = 'brzycki-assignment-backend-dev'

param dev_service_frontend string = 'brzycki-assignment-frontend-dev'
@sys.description('The App Service Plan name.')

param dev_service string = 'brzycki-assignment-dev'
@sys.description('The Storage Account name.')

param storageAccountName string = 'brzyckistorage'
@allowed([
  'nonprod'
  'prod'
  ])
param environmentType string = 'nonprod'
param runtimeStack1 string = 'Python|3.10'
param runtimeStack2 string = 'Node|14-lts'
param startupCommand1 string = 'pm2 serve /home/site/wwwroot/dist --no-daemon --spa'
param location string = resourceGroup().location
@secure()
param dbhost string
@secure()
param dbuser string
@secure()
param dbpass string
@secure()
param dbname string

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'  

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
    name: storageAccountName
    location: location
    sku: {
      name: storageAccountSkuName
    }
    kind: 'StorageV2'
    properties: {
      accessTier: 'Hot'
    }
  }

module prod_App_backend 'modules/application_one.bicep' = if (environmentType == 'prod') {
  name: 'prod_App_backend'
  params: { 
    location: location
    appServiceAppName: prod_service_backend
    appServicePlanName: prod_service
    runtimeStack: runtimeStack1
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

module prod_App_frontend 'modules/application_two.bicep' = if (environmentType == 'prod') {
  name: 'prod_App_frontend'
  params: { 
    location: location
    appServiceAppName: prod_service_frontend
    appServicePlanName: prod_service
    runtimeStack: runtimeStack2
    startupCommand: startupCommand1
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

module dev_App_backend 'modules/application_one.bicep' = if (environmentType == 'nonprod') {
  name: 'dev_App_backend'
  params: { 
    location: location
    appServiceAppName: dev_service_backend
    appServicePlanName: dev_service
    runtimeStack: runtimeStack1
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

module dev_App_frontend 'modules/application_two.bicep' = if (environmentType == 'nonprod') {
  name: 'dev_App_frontend'
  params: { 
    location: location
    appServiceAppName: dev_service_frontend
    appServicePlanName: dev_service
    runtimeStack: runtimeStack2
    startupCommand: startupCommand1
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

  output appServiceAppHostName1 string = (environmentType == 'prod') ? prod_App_backend.outputs.appServiceAppHostName : dev_App_backend.outputs.appServiceAppHostName
  output appServiceAppHostName2 string = (environmentType == 'prod') ? prod_App_frontend.outputs.appServiceAppHostName : dev_App_frontend.outputs.appServiceAppHostName
