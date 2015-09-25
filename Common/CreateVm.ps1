function GetWinVmConfig($cloudServiceName, $serverName, $instanceSize, $availabilitySetName, $subnetName, $IP)
{
    $vm = New-AzureVMConfig `
            -Name $serverName `
            -InstanceSize $instanceSize `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$serverName.vhd" `
            -AvailabilitySetName $availabilitySetName `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Windows `
                -DisableAutomaticUpdates `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword |
                    Set-AzureSubnet $subnetName |
                        Set-AzureStaticVNetIP -IPAddress $IP
                
    return $vm
}

function CreateLinuxVmChecked($cloudServiceName, $serverName, $instanceSize, $availabilitySetName, $subnetName, $IP)
{
    $vm = Get-AzureVM -ServiceName $cloudServiceName -Name $serverName

    if ($vm -eq $null)
    {
        CreateLinuxVm $cloudServiceName $serverName $instanceSize $availabilitySetName $subnetName $IP
    }
}

function CreateLinuxVm($cloudServiceName, $serverName, $instanceSize, $availabilitySetName, $subnetName, $IP)
{
    New-AzureVMConfig `
        -Name $serverName `
        -InstanceSize $instanceSize `
        -ImageName $linuxImageName `
        -MediaLocation "$storageAccountContainer$serverName.vhd" `
        -AvailabilitySetName $availabilitySetName `
        -DiskLabel "OS" | 
        Add-AzureProvisioningConfig `
            -Linux `
            -LinuxUser $vmAdminUser `
            -Password $vmAdminPassword `
            -NoSSHEndpoint |
            Set-AzureSubnet -SubnetNames $subnetName |
                Set-AzureStaticVNetIP -IPAddress $IP |
				    New-AzureVM `
					    -ServiceName $cloudServiceName `
                        -WaitForBoot
}