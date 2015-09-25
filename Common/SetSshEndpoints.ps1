function SetSshEndpoints($serverName, $port)
{
    Get-AzureVM -ServiceName $cloudServiceName -Name $serverName |
        Add-AzureEndpoint -Name "SSH" `
                            -Protocol tcp `
                            -PublicPort $port `
                            -LocalPort 22 |
            Update-AzureVM
}

function EnableSshFirewall($serverName)
{
    $enableSshScriptBlock =
    {
        New-NetFirewallRule -Name "SSH" -DisplayName "SSH" -LocalPort 22 -Protocol TCP
    }
    
    RunRemotely $vmAdminUser $vmAdminPassword $cloudServiceName $serverName $enableSshScriptBlock
}


Write-Status "Setting SSH Endpoints..."

SetSshEndpoints $webServerName0   20022 
SetSshEndpoints $webServerName1   20122
SetSshEndpoints $webServerName2   20222
SetSshEndpoints $webServerName3   20322 
SetSshEndpoints $webServerName4   20422
SetSshEndpoints $webServerName5   20522
SetSshEndpoints $webServerName6   20622 
SetSshEndpoints $webServerName7   20722
SetSshEndpoints $webServerName8   20822

SetSshEndpoints $servicesServerName0 25022
SetSshEndpoints $servicesServerName1 25122

SetSshEndpoints $memcachedServerName0 27022
SetSshEndpoints $memcachedServerName1 27122


Write-Status "Enable SSH Firewalls..."

EnableSshFirewall $webServerName0
EnableSshFirewall $webServerName1
EnableSshFirewall $webServerName2
EnableSshFirewall $webServerName3
EnableSshFirewall $webServerName4
EnableSshFirewall $webServerName5
EnableSshFirewall $webServerName6
EnableSshFirewall $webServerName7
EnableSshFirewall $webServerName8

EnableSshFirewall $servicesServerName0
EnableSshFirewall $servicesServerName1