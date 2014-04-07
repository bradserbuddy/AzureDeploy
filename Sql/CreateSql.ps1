function CreateSql($workingDir)
{
    . $workingDir"Sql\CopySqlImage.ps1"
    & CopySqlImage

    $sqlImageName = "SQLImage$storageAccountName"


    # Create SQL 1

    $VMStatus = Get-AzureVM -ServiceName $sqlCloudServiceName -Name $sql1ServerName

    if ($VMStatus.InstanceStatus -ne "ReadyRole")
    {
        New-AzureVMConfig `
            -Name $sql1ServerName `
            -InstanceSize Large `
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
                    -SubnetNames $subnetName |
                    Add-AzureEndpoint `
                        -Name "SQL" `
                        -Protocol "tcp" `
                        -PublicPort 1 `
                        -LocalPort 1433 | 
                         New-AzureVM -ServiceName $sqlCloudServiceName

        . $workingDir"\Common\WaitForVM.ps1"
        Wait-ForVM $sqlCloudServiceName $sql1ServerName
    }   

    # Create SQL 2

    $VMStatus = Get-AzureVM -ServiceName $sqlCloudServiceName -Name $sql2ServerName

    if ($VMStatus.InstanceStatus -ne "ReadyRole")
    {
        New-AzureVMConfig `
            -Name $sql2ServerName `
            -InstanceSize Large `
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
                    -SubnetNames $subnetName |
                    Add-AzureEndpoint `
                        -Name "SQL" `
                        -Protocol "tcp" `
                        -PublicPort 2 `
                        -LocalPort 1433 | 
                        New-AzureVM -ServiceName $sqlCloudServiceName

        . $workingDir"\Common\WaitForVM.ps1"
        Wait-ForVM $sqlCloudServiceName $sql2ServerName
    } 
}