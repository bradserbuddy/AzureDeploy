function SetWebEndpoints($serverName, $port)
{
    Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
        Add-AzureEndpoint -Name "SSH" `
                            -Protocol tcp `
                            -PublicPort $port `
                            -LocalPort 22 |
            Update-AzureVM
}

SetSshEndpoints $webServerName1   20022 
SetSshEndpoints $webServerName2   20122
SetSshEndpoints $dcServerName2    21022
SetSshEndpoints $mongoServerName1 22022
SetSshEndpoints $mongoServerName2 22122