function GetWinVmConfig($cloudServiceName, $serverName, $instanceSize, $availabilitySetName)
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
                -Password $vmAdminPassword
                
    return $vm
}

function CreateLinuxVmChecked($cloudServiceName, $serverName, $instanceSize, $availabilitySetName)
{
    $vm = Get-AzureVM -ServiceName $cloudServiceName -Name $serverName

    if ($vm -eq $null)
    {
        CreateLinuxVm $cloudServiceName $serverName $instanceSize $availabilitySetName
    }
}

function CreateLinuxVm($cloudServiceName, $serverName, $instanceSize, $availabilitySetName)
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
            Set-AzureSubnet `
                -SubnetNames $frontSubnetName |
				New-AzureVM `
					-ServiceName $cloudServiceName `
                    -WaitForBoot
}