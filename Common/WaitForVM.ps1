function Wait-ForVM($serviceName, $serverName)
{
    $VMStatus = Get-AzureVM -ServiceName $serviceName -Name $serverName

    While ($VMStatus.InstanceStatus -ne "ReadyRole")
    {
        write-host "Waiting for " $VMStatus.Name "... Current Status = " $VMStatus.InstanceStatus
        Start-Sleep -Seconds 15
        $VMStatus = Get-AzureVM -ServiceName $serviceName -Name $serverName
    }

    Get-AzureRemoteDesktopFile `
        -ServiceName $serviceName `
        -Name $serverName `
        -LocalPath "$workingDir$serverName.rdp" 
}