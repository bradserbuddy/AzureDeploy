function SetWebEndpoints($serverName, $apiName, $apiPorts, $devDashName, $devDashPorts)
{
Write-Status "SetWebEndpoints"

    Get-AzureVM -ServiceName $cloudServiceName -Name $serverName |
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
Write-Status "CreateLBWebEndpoints"

    Get-AzureVM -ServiceName $cloudServiceName -Name $serverName |
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
    
    RunRemotely $vmAdminUser $vmAdminPassword $cloudServiceName $serverName $enableHttpScriptBlock
}

SetWebEndpoints $webServerName0 "Test API" 9080,9080 "Test Dev Dash" 9081,9081
SetWebEndpoints $webServerName1 "Test API" 9180,9080 "Test Dev Dash" 9181,9081
SetWebEndpoints $webServerName2 "Test API" 9280,9080 "Test Dev Dash" 9281,9081
SetWebEndpoints $webServerName3 "Test API" 9380,9080 "Test Dev Dash" 9381,9081
SetWebEndpoints $webServerName4 "Test API" 9480,9080 "Test Dev Dash" 9481,9081
SetWebEndpoints $webServerName5 "Test API" 9580,9080 "Test Dev Dash" 9581,9081
SetWebEndpoints $webServerName6 "Test API" 9680,9080 "Test Dev Dash" 9681,9081
SetWebEndpoints $webServerName7 "Test API" 9780,9080 "Test Dev Dash" 9781,9081
SetWebEndpoints $webServerName8 "Test API" 9880,9080 "Test Dev Dash" 9881,9081

SetWebEndpoints $webServerName0 "Direct API" 10080,10080 "Direct Dev Dash" 10081,10081 
SetWebEndpoints $webServerName1 "Direct API" 10180,10080 "Direct Dev Dash" 10181,10081
SetWebEndpoints $webServerName2 "Direct API" 10280,10080 "Direct Dev Dash" 10281,10081
SetWebEndpoints $webServerName3 "Direct API" 10380,10080 "Direct Dev Dash" 10381,10081 
SetWebEndpoints $webServerName4 "Direct API" 10480,10080 "Direct Dev Dash" 10481,10081
SetWebEndpoints $webServerName5 "Direct API" 10580,10080 "Direct Dev Dash" 10581,10081
SetWebEndpoints $webServerName6 "Direct API" 10680,10080 "Direct Dev Dash" 10681,10081 
SetWebEndpoints $webServerName7 "Direct API" 10780,10080 "Direct Dev Dash" 10781,10081
SetWebEndpoints $webServerName8 "Direct API" 10880,10080 "Direct Dev Dash" 10881,10081

CreateLBWebEndpoints $webServerName0
CreateLBWebEndpoints $webServerName1
CreateLBWebEndpoints $webServerName2
CreateLBWebEndpoints $webServerName3
CreateLBWebEndpoints $webServerName4
CreateLBWebEndpoints $webServerName5

EnableHttpFirewall $webServerName0 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName1 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName2 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName3 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName4 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName5 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName6 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName7 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName8 8080,9080,9081,10080,10081,81