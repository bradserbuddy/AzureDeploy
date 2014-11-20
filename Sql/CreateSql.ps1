function CreateSql()
{
    #. $workingDir"Sql\CopySqlImage.ps1"
    #& CopySqlImage

    #$sqlImageName = "SQLImage$storageAccountName"
    $sqlImageName = $winImageName

    Write-Status "Creating Sql 1..."
    CreateSqlVm $sqlServerName1 1

    Write-Status "Creating Sql 2..."
    CreateSqlVm $sqlServerName2 2
}

function CreateSqlVm($sqlServerName, $publicPort)
{
    $vm = Get-AzureVM -ServiceName $sqlCloudServiceName -Name $sqlServerName

    if ($vm.InstanceStatus -ne "ReadyRole")
    {
        New-AzureVMConfig `
            -Name $sqlServerName `
            -InstanceSize $Standard_A3 `
            -ImageName $sqlImageName `
            -MediaLocation "$storageAccountContainer$sqlServerName.vhd" `
            -AvailabilitySetName $sqlAvailabilitySetName `
            -HostCaching ReadOnly `
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
                         New-AzureVM -ServiceName $sqlCloudServiceName -WaitForBoot

        Get-AzureVM -ServiceName $sqlCloudServiceName -Name $sqlServerName |
            Add-AzureDataDisk -CreateNew -DiskSizeInGB 200 -DiskLabel "Datadrive" -LUN 0 |
                Update-AzureVM

        RdpManageCert $sqlCloudServiceName $sqlServerName
    }
}