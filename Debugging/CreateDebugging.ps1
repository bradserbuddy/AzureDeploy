function CreateDebugging()
{
    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $stagingServerName

    if ($vm -eq $null)
    {
        $vm = GetWinVmConfig $dcCloudServiceName $debuggingServerName $Basic_A2 $debuggingAvailabilitySetName

        $vm | Set-AzureSubnet `
                -SubnetNames $frontSubnetName |
				New-AzureVM `
					-ServiceName $dcCloudServiceName `
                    -WaitForBoot

        RdpManageCert $dcCloudServiceName $debuggingServerName
    }
}