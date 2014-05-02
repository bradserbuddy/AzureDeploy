function CreateStaging()
{
    $winImageName = (Get-AzureVMImage | where {$_.Label -like "Windows Server 2012 R2 Datacenter*"} | sort PublishedDate -Descending)[0].ImageName

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $stagingServerName

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $stagingServerName `
            -InstanceSize Basic_A1 `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$stagingServerName.vhd" `
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
            -Name $stagingServerName `
            -LocalPath "$workingDir$stagingServerName.rdp"
    }

    # mkdir c:\buddyapps 
    # NET SHARE buddyapps=c:\buddyapps /GRANT:Everyone,FULL
}