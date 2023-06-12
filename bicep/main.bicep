/*
* Notice: Any links, references, or attachments that contain sample scripts, code, or commands comes with the following notification.
*
* This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
* THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
* INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
*
* We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code,
* provided that You agree:
*
* (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded;
* (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and
* (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits,
* including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
*
* Please note: None of the conditions outlined in the disclaimer above will superseded the terms and conditions contained within the Premier Customer Services Description.
*
* DEMO POC - "AS IS"
*/
targetScope='subscription'

param location string
@secure()
param publisherEmail string
@secure()
param publisherName string

var rgName = 'rg-soap-apim'

var suffix = uniqueString(rg.id)

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
}

module monitoring 'modules/monitoring/monitoring.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'monitoring'
  params: {
    location: location
    suffix: suffix
  }
}


module apim 'modules/apim/apim.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'apim'
  params: {
    administratorEmail: publisherEmail
    location: location
    organizationName: publisherName
    suffix: suffix
  }
}

module asp 'modules/web/asp.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'asp'
  params: {
    location: location
    suffix: suffix
  }
}

module web 'modules/web/web.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'web'
  params: {
    appInsightName: monitoring.outputs.appInsightName
    appServiceId: asp.outputs.aspId
    location: location
    suffix: suffix
  }
}


output rgName string = rg.name
output apimName string = apim.outputs.apimName
output webAppName string = web.outputs.soapWebName
