function CreateDc()
{
    # TODO: Add-AzureDataDisk adds the data disk that you will use for storing Active Directory data, with caching option set to None. - not sure how important this is

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $dcServerName

    if ($vm -eq $null)
    {
        $vm = GetWinVmConfig $dcCloudServiceName $dcServerName $Basic_A2 $servicesAvailabilitySetName
     
        $vm | New-AzureVM `
                -ServiceName $dcCloudServiceName `
                –AffinityGroup $affinityGroupName `
                -VNetName $virtualNetworkName `
                -WaitForBoot

        RdpManageCert $dcCloudServiceName $dcServerName
    }
}

function CreateServices2()
{
    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $servicesServerName2

    if ($vm -eq $null)
    {
        $vm = GetWinVmConfig $dcCloudServiceName $servicesServerName2 $Basic_A2 $servicesAvailabilitySetName

        $vm | Set-AzureSubnet `
                -SubnetNames $frontSubnetName |
			    New-AzureVM `
				    -ServiceName $dcCloudServiceName `
                    -WaitForBoot

        RdpManageCert $dcCloudServiceName $servicesServerName2
    }
}