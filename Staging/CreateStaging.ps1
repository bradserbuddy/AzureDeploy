function CreateStaging()
{
    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $stagingServerName

    if ($vm -eq $null)
    {
        $vm = GetWinVmConfig $dcCloudServiceName $stagingServerName $Basic_A2

        $vm | Set-AzureSubnet `
                -SubnetNames $frontSubnetName |
				New-AzureVM `
					-ServiceName $dcCloudServiceName `
                    -WaitForBoot

        RdpManageCert $dcCloudServiceName $stagingServerName
    }
}