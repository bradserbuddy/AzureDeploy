function CreateQuorum()
{
    $winImageName = (Get-AzureVMImage | where {$_.Label -like "Windows Server 2012 R2 Datacenter*"} | sort PublishedDate -Descending)[0].ImageName

    $vm = Get-AzureVM -ServiceName $sqlCloudServiceName -Name $quorumServerName

    if ($vm.InstanceStatus -ne "ReadyRole")
    {
        New-AzureVMConfig `
            -Name $quorumServerName `
            -InstanceSize Basic_A1 `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$quorumServerName.vhd" `
            -AvailabilitySetName $azureAvailabilitySetName `
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
                    New-AzureVM `
                        -ServiceName $sqlCloudServiceName `
                        –AffinityGroup $affinityGroupName `
                        -VNetName $virtualNetworkName `
                        -DnsSettings $dnsSettings `
                        -WaitForBoot

        Get-AzureRemoteDesktopFile `
            -ServiceName $sqlCloudServiceName `
            -Name $quorumServerName `
            -LocalPath "$workingDir$quorumServerName.rdp"

        . $workingDir"External\InstallWinRMCertAzureVM.ps1" -SubscriptionName $subscriptionName -ServiceName $sqlCloudServiceName -Name $quorumServerName
    }
}