﻿function CreateWeb()
{
    $winImageName = (Get-AzureVMImage | where {$_.Label -like "Windows Server 2012 R2 Datacenter*"} | sort PublishedDate -Descending)[0].ImageName

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $webServerName1

    $installAspNetScriptBlock =
    {
        Install-WindowsFeature -Name Web-Asp-Net45, Web-Asp-Net, AS-NET-Framework, AS-Web-Support
    }

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $webServerName1 `
            -InstanceSize Standard_A2 `
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

        RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $webServerName1 $installAspNetScriptBlock
    }

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $webServerName2

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $webServerName2 `
            -InstanceSize Standard_A2 `
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

        RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $webServerName2 $installAspNetScriptBlock
    }

    # mkdir c:\buddyapps 
    # NET SHARE buddyapps=c:\buddyapps /GRANT:Everyone,FULL
}