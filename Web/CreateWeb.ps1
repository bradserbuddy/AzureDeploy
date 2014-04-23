function CreateWeb()
{
    # Missing -> Add-AzureDataDisk adds the data disk that you will use for storing Active Directory data, with caching option set to None.

    $winImageName = (Get-AzureVMImage | where {$_.Label -like "Windows Server 2012 R2 Datacenter*"} | sort PublishedDate -Descending)[0].ImageName

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $webServerName1

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $webServerName1 `
            -InstanceSize Medium `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$webServerName1.vhd" `
            -AvailabilitySetName $azureAvailabilitySetName `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Windows `
                -DisableAutomaticUpdates `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword |
                Set-AzureSubnet `
                    -SubnetNames $frontSubnetName |
					New-AzureVM `
						-ServiceName $dcCloudServiceName `
                        -WaitForBoot

        Get-AzureRemoteDesktopFile `
            -ServiceName $dcCloudServiceName `
            -Name $webServerName1 `
            -LocalPath "$workingDir$webServerName1.rdp"

        . $workingDir"External\InstallWinRMCertAzureVM.ps1" -SubscriptionName $subscriptionName -ServiceName $dcCloudServiceName -Name $webServerName1
    }

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $webServerName2

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $webServerName2 `
            -InstanceSize Medium `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$webServerName2.vhd" `
            -AvailabilitySetName $azureAvailabilitySetName `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Windows `
                -DisableAutomaticUpdates `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword |
                Set-AzureSubnet `
                    -SubnetNames $frontSubnetName |
					New-AzureVM `
						-ServiceName $dcCloudServiceName `
                        -WaitForBoot

        Get-AzureRemoteDesktopFile `
            -ServiceName $dcCloudServiceName `
            -Name $webServerName2 `
            -LocalPath "$workingDir$webServerName2.rdp"

        . $workingDir"External\InstallWinRMCertAzureVM.ps1" -SubscriptionName $subscriptionName -ServiceName $dcCloudServiceName -Name $webServerName2
    }

#TODO: create master\web1 share for slave\web2
}