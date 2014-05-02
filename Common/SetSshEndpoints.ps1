﻿function SetSshEndpoints($serverName, $port)
{
    Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
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
    
    RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $serverName $enableSshScriptBlock
}

SetSshEndpoints $webServerName1   20022 
SetSshEndpoints $webServerName2   20122
SetSshEndpoints $dcServerName     21022
SetSshEndpoints $mongoServerName1 22022
SetSshEndpoints $mongoServerName2 22122

EnableSshFirewall $webServerName1
EnableSshFirewall $webServerName2
EnableSshFirewall $dcServerName