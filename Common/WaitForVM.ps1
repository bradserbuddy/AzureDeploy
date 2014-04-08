function WaitAndDownloadRDF-ForVM($serviceName, $serverName)
{
    Wait-ForVM($serviceName, $serverName)

    Get-AzureRemoteDesktopFile `
        -ServiceName $serviceName `
        -Name $serverName `
        -LocalPath "$workingDir$serverName.rdp" 
}

function Wait-ForVM($serviceName, $serverName)
{
    $vm = Get-AzureVM -ServiceName $serviceName -Name $serverName

    While ($vm.InstanceStatus -ne "ReadyRole")
    {
        write-host "Waiting for " $vm.Name "... Current Status = " $vm.InstanceStatus
        Start-Sleep -Seconds 15
        $vm = Get-AzureVM -ServiceName $serviceName -Name $serverName
    }
}