Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common $workingDir

function SetWebEndpoints($serverName)
{
    Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
        Add-AzureEndpoint -Name "Direct API" `
                            -Protocol tcp `
                            -PublicPort 10080 `
                            -LocalPort 10080 |
        Add-AzureEndpoint -Name "Direct Dev Dash" `
                            -Protocol tcp `
                            -PublicPort 10081 `
                            -LocalPort 10081 |
        Add-AzureEndpoint -Name "Http" `
                            -LBSetName "eus-http" `
                            -Protocol tcp `
                            -PublicPort 80 `
                            -LocalPort 8080 `
                            -DefaultProbe |
        Add-AzureEndpoint -Name "Https" `
                            -LBSetName "eus-ssl" `
                            -Protocol tcp `
                            -PublicPort 443 `
                            -LocalPort 443 `
                            -DefaultProbe |
            Update-AzureVM
}

SetWebEndpoints($webServerName1)
SetWebEndpoints($webServerName2)
