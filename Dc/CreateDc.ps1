function CreateDc($workingDir)
{
    # Missing -> Add-AzureDataDisk adds the data disk that you will use for storing Active Directory data, with caching option set to None.

    $winImageName = (Get-AzureVMImage | where {$_.Label -like "Windows Server 2012 R2 Datacenter*"} | sort PublishedDate -Descending)[0].ImageName

    $VMStatus = Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName

    if ($VMStatus -eq $null)
    {
        New-AzureVMConfig `
            -Name $dcServerName `
            -InstanceSize Medium `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$dcServerName.vhd" `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Windows `
                -DisableAutomaticUpdates `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword |
                New-AzureVM `
                    -ServiceName $dcCloudServiceName `
                    –AffinityGroup $affinityGroupName `
                    -VNetName $virtualNetworkName

        . $workingDir"\Common\WaitForVM.ps1"
        Wait-ForVM $dcCloudServiceName $dcServerName
    }
}