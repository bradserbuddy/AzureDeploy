function CreateDc()
{
    # TODO: Add-AzureDataDisk adds the data disk that you will use for storing Active Directory data, with caching option set to None. - not sure how important this is

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $dcServerName

    if ($vm -eq $null)
    {
        $vm = GetWinVmConfig $dcCloudServiceName $dcServerName $Basic_A2
     
        $vm | New-AzureVM `
                -ServiceName $dcCloudServiceName `
                –AffinityGroup $affinityGroupName `
                -VNetName $virtualNetworkName `
                -WaitForBoot

        RdpManageCert $dcCloudServiceName $dcServerName
    }
}

function CreateQueue2()
{
    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $queueServerName2

    if ($vm -eq $null)
    {
        $vm = GetWinVmConfig $dcCloudServiceName $queueServerName2 $Basic_A2

        $vm | Set-AzureSubnet `
                -SubnetNames $frontSubnetName |
			    New-AzureVM `
				    -ServiceName $dcCloudServiceName `
                    -WaitForBoot

        RdpManageCert $dcCloudServiceName $queueServerName2
    }
}