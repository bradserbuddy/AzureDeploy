function CreateDebugging()
{
    $vm = Get-AzureVM -ServiceName $cloudServiceName -Name $debuggingServerName

    if ($vm -eq $null)
    {
        $vm = GetWinVmConfig $cloudServiceName $debuggingServerName $Basic_A2 $debuggingAvailabilitySetName $frontEndSubnetName $debuggingServerIP

        $vm | New-AzureVM `
					-ServiceName $cloudServiceName `
                    -WaitForBoot

        RdpManageCert $cloudServiceName $debuggingServerName
    }
}