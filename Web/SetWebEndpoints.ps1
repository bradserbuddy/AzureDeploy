﻿function SetWebEndpoints($serverName, $apiName, $apiPorts, $devDashName, $devDashPorts)
{
    Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
        Add-AzureEndpoint -Name $apiName `
                            -Protocol TCP `
                            -PublicPort $apiPorts[0] `
                            -LocalPort $apiPorts[1] |
        Add-AzureEndpoint -Name $devDashName `
                            -Protocol TCP `
                            -PublicPort $devDashPorts[0] `
                            -LocalPort $devDashPorts[1] |
            Update-AzureVM
}

function CreateLBWebEndpoints($serverName)
{
    Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
        Add-AzureEndpoint -Name "HTTP" `
                            -LBSetName "$locationAbbrev-http" `
                            -Protocol TCP `
                            -PublicPort 80 `
                            -LocalPort 8080 `
                            -ProbeProtocol HTTP `
                            -ProbePath "/" `
                            -ProbePort 8080 |
        Add-AzureEndpoint -Name "HTTP Dev Dash" `
                            -LBSetName "$locationAbbrev-http-dd" `
                            -Protocol TCP `
                            -PublicPort 81 `
                            -LocalPort 81 `
                            -ProbeProtocol HTTP `
                            -ProbePath "/" `
                            -ProbePort 81 |
        Add-AzureEndpoint -Name "HTTPS" `
                            -LBSetName "$locationAbbrev-ssl" `
                            -Protocol TCP `
                            -PublicPort 443 `
                            -LocalPort 443 `
                            -ProbeProtocol HTTP `
                            -ProbePath "/_admin/status" `
                            -ProbePort 10080 |
            Update-AzureVM
}

function EnableHttpFirewall($serverName, $ports)
{
    $enableHttpScriptBlock =
    {
        $portPrefix ="HTTP"

        $localPorts = $Using:ports

        # New-NetFirewallRule\Set-NetFirewallRule doesn't accept individual ports
        for ($i = 0; $i -lt $localPorts.Count; $i++)
        {
            $localPort = $localPorts[$i]

            New-NetFirewallRule -Name "$portPrefix $localPort" -DisplayName "$portPrefix $localPort" -LocalPort $localPort -Protocol TCP
        }
    }
    
    RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $serverName $enableHttpScriptBlock
}

SetWebEndpoints $webServerName1 "Test API" 9080,9080 "Test Dev Dash" 9081,9081
SetWebEndpoints $webServerName2 "Test API" 9180,9080 "Test Dev Dash" 9181,9081
SetWebEndpoints $webServerName3 "Test API" 9280,9080 "Test Dev Dash" 9281,9081

SetWebEndpoints $webServerName1 "Direct API" 10080,10080 "Direct Dev Dash" 10081,10081 
SetWebEndpoints $webServerName2 "Direct API" 10180,10080 "Direct Dev Dash" 10181,10081
SetWebEndpoints $webServerName3 "Direct API" 10280,10080 "Direct Dev Dash" 10281,10081

CreateLBWebEndpoints $webServerName1
CreateLBWebEndpoints $webServerName2
CreateLBWebEndpoints $webServerName3

EnableHttpFirewall $webServerName1 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName2 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName3 8080,9080,9081,10080,10081,81