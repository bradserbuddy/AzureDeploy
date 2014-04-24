#TODO: verify firewall\Azure ports match up with bindings

function SetWebEndpoints($serverName, $directApi, $directDevDash)
{
    Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
        Add-AzureEndpoint -Name "Direct API" `
                            -Protocol tcp `
                            -PublicPort $directApi `
                            -LocalPort $directApi |
        Add-AzureEndpoint -Name "Direct Dev Dash" `
                            -Protocol tcp `
                            -PublicPort $directDevDash `
                            -LocalPort $directDevDash |
        Add-AzureEndpoint -Name "Http" `
                            -LBSetName "$locationAbbrev-http" `
                            -Protocol tcp `
                            -PublicPort 80 `
                            -LocalPort 80 `
                            -DefaultProbe |
        Add-AzureEndpoint -Name "Https" `
                            -LBSetName "$locationAbbrev-ssl" `
                            -Protocol tcp `
                            -PublicPort 443 `
                            -LocalPort 443 `
                            -DefaultProbe |
            Update-AzureVM
}

SetWebEndpoints $webServerName1 10080 10081 
SetWebEndpoints $webServerName2 10180 10181