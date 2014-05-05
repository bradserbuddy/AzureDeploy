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
        Add-AzureEndpoint -Name "HTTP" `
                            -LBSetName "$locationAbbrev-http" `
                            -Protocol tcp `
                            -PublicPort 80 `
                            -LocalPort 8080 `
                            -DefaultProbe |
        Add-AzureEndpoint -Name "HTTP Dev Dash" `
                            -LBSetName "$locationAbbrev-http-dd" `
                            -Protocol tcp `
                            -PublicPort 81 `
                            -LocalPort 81 `
                            -DefaultProbe |
        Add-AzureEndpoint -Name "HTTPS" `
                            -LBSetName "$locationAbbrev-ssl" `
                            -Protocol tcp `
                            -PublicPort 443 `
                            -LocalPort 443 `
                            -DefaultProbe |
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
            New-NetFirewallRule -Name "$portPrefix$i" -DisplayName "$portPrefix$i" -LocalPort $localPorts[$i] -Protocol TCP
        }
    }
    
    RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $serverName $enableHttpScriptBlock
}

SetWebEndpoints $webServerName1 "Test API" 9080 "Test Dev Dash" 9081
SetWebEndpoints $webServerName2 "Test API" 9180 "Test Dev Dash" 9181 

SetWebEndpoints $webServerName1 "Direct API" 10080 "Direct Dev Dash" 10081 
SetWebEndpoints $webServerName2 "Direct API" 10180 "Direct Dev Dash" 10181

SetLBWebEndpoints $webServerName1
SetLBWebEndpoints $webServerName2

EnableHttpFirewall $webServerName1 8080,9080,9081,10080,10081,81
EnableHttpFirewall $webServerName2 8080,9180,9181,10180,10181,81