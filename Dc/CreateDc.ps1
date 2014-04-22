function CreateDc()
{
    # Missing -> Add-AzureDataDisk adds the data disk that you will use for storing Active Directory data, with caching option set to None.

    $winImageName = (Get-AzureVMImage | where {$_.Label -like "Windows Server 2012 R2 Datacenter*"} | sort PublishedDate -Descending)[0].ImageName

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $dcServerName

    if ($vm -eq $null)
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
                    -VNetName $virtualNetworkName `
                    -WaitForBoot

        Get-AzureRemoteDesktopFile `
            -ServiceName $dcCloudServiceName `
            -Name $dcServerName `
            -LocalPath "$workingDir$dcServerName.rdp" 

        . $workingDir"External\InstallWinRMCertAzureVM.ps1" -SubscriptionName $subscriptionName -ServiceName $dcCloudServiceName -Name $dcServerName
    }
}