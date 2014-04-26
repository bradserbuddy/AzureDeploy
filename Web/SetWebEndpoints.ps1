function SetWebEndpoints($serverName, $apiName, $apiPort, $devDashName, $devDashPort)
{
    Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
        Add-AzureEndpoint -Name $apiName `
                            -Protocol tcp `
                            -PublicPort $apiPort `
                            -LocalPort $apiPort |
        Add-AzureEndpoint -Name $devDashName `
                            -Protocol tcp `
                            -PublicPort $devDashPort `
                            -LocalPort $devDashPort |
            Update-AzureVM
}

function SetLBWebEndpoints($serverName)
{
    Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
        Add-AzureEndpoint -Name "Http" `
                            -LBSetName "$locationAbbrev-http" `
                            -Protocol tcp `
                            -PublicPort 80 `
                            -LocalPort 80 `
                            -DefaultProbe |
        Add-AzureEndpoint -Name "Http Dev Dash" `
                            -LBSetName "$locationAbbrev-http-dd" `
                            -Protocol tcp `
                            -PublicPort 81 `
                            -LocalPort 81 `
                            -DefaultProbe |
        Add-AzureEndpoint -Name "Https" `
                            -LBSetName "$locationAbbrev-ssl" `
                            -Protocol tcp `
                            -PublicPort 443 `
                            -LocalPort 443 `
                            -DefaultProbe |
            Update-AzureVM
}


SetWebEndpoints $webServerName1 "Test API" 9080 "Test Dev Dash" 9081
SetWebEndpoints $webServerName2 "Test API" 9180 "Test Dev Dash" 9181 

SetWebEndpoints $webServerName1 "Direct API" 10080 "Direct Dev Dash" 10081 
SetWebEndpoints $webServerName2 "Direct API" 10180 "Direct Dev Dash" 10181

SetLBWebEndpoints $webServerName1
SetLBWebEndpoints $webServerName2