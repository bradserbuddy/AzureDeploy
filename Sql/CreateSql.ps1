function CreateSql()
{
    . $workingDir"Sql\CopySqlImage.ps1"
    & CopySqlImage

    $sqlImageName = "SQLImage$storageAccountName"


    # Create SQL 1

    $vm = Get-AzureVM -ServiceName $sqlCloudServiceName -Name $sql1ServerName

    if ($vm.InstanceStatus -ne "ReadyRole")
    {
        New-AzureVMConfig `
            -Name $sql1ServerName `
            -InstanceSize Basic_A3 `
            -ImageName $sqlImageName `
            -MediaLocation "$storageAccountContainer$sql1ServerName.vhd" `
            -AvailabilitySetName $azureAvailabilitySetName `
            -HostCaching "ReadOnly" `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -WindowsDomain `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword `
                -DisableAutomaticUpdates `
                -Domain $domainName `
                -JoinDomain $FQDN `
                -DomainUserName $vmAdminUser `
                -DomainPassword $vmAdminPassword |
                Set-AzureSubnet `
                    -SubnetNames $backSubnetName |
                    Add-AzureEndpoint `
                        -Name "SQL" `
                        -Protocol "tcp" `
                        -PublicPort 1 `
                        -LocalPort 1434 | 
                         New-AzureVM -ServiceName $sqlCloudServiceName -WaitForBoot

        Get-AzureVM -ServiceName $sqlCloudServiceName -Name $sql1ServerName |
            Add-AzureDataDisk -CreateNew -DiskSizeInGB 200 -DiskLabel "SQL" -LUN 0 |
                Update-AzureVM

        Get-AzureRemoteDesktopFile `
            -ServiceName $sqlCloudServiceName `
            -Name $sql1ServerName `
            -LocalPath "$workingDir$sql1ServerName.rdp" 

        . $workingDir"External\InstallWinRMCertAzureVM.ps1" -SubscriptionName $subscriptionName -ServiceName $sqlCloudServiceName -Name $sql1ServerName
    }   

    # Create SQL 2

    $vm = Get-AzureVM -ServiceName $sqlCloudServiceName -Name $sql2ServerName

    if ($vm.InstanceStatus -ne "ReadyRole")
    {
        New-AzureVMConfig `
            -Name $sql2ServerName `
            -InstanceSize Basic_A3 `
            -ImageName $sqlImageName `
            -MediaLocation "$storageAccountContainer$sql2ServerName.vhd" `
            -AvailabilitySetName $azureAvailabilitySetName `
            -HostCaching "ReadOnly" `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -WindowsDomain `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword `
                -DisableAutomaticUpdates `
                -Domain $domainName `
                -JoinDomain $FQDN `
                -DomainUserName $vmAdminUser `
                -DomainPassword $vmAdminPassword |
                Set-AzureSubnet `
                    -SubnetNames $backSubnetName |
                    Add-AzureEndpoint `
                        -Name "SQL" `
                        -Protocol "tcp" `
                        -PublicPort 2 `
                        -LocalPort 1434 | 
                        New-AzureVM -ServiceName $sqlCloudServiceName -WaitForBoot

        Get-AzureVM -ServiceName $sqlCloudServiceName -Name $sql2ServerName |
            Add-AzureDataDisk -CreateNew -DiskSizeInGB 200 -DiskLabel "SQL" -LUN 0 |
                Update-AzureVM

        Get-AzureRemoteDesktopFile `
            -ServiceName $sqlCloudServiceName `
            -Name $sql2ServerName `
            -LocalPath "$workingDir$sql2ServerName.rdp" 

        . $workingDir"External\InstallWinRMCertAzureVM.ps1" -SubscriptionName $subscriptionName -ServiceName $sqlCloudServiceName -Name $sql2ServerName
    } 
}