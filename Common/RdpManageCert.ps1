function RdpManageCert($cloudServiceName, $serverName)
{
    Get-AzureRemoteDesktopFile `
        -ServiceName $cloudServiceName `
        -Name $serverName `
        -LocalPath "$workingDir$serverName.rdp" 

    . $workingDir"External\InstallWinRMCertAzureVM.ps1" -SubscriptionName $subscriptionName -ServiceName $cloudServiceName -Name $serverName
}