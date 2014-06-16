function GetWinVmConfig($cloudServiceName, $serverName, $instanceSize)
{
    $vm = New-AzureVMConfig `
            -Name $serverName `
            -InstanceSize $instanceSize `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$serverName.vhd" `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Windows `
                -DisableAutomaticUpdates `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword
                
    return $vm
}

function CreateLinuxVmChecked($cloudServiceName, $serverName, $instanceSize)
{
    $vm = Get-AzureVM -ServiceName $cloudServiceName -Name $serverName

    if ($vm -eq $null)
    {
        CreateLinuxVm $cloudServiceName $serverName $instanceSize
    }
}

function CreateLinuxVm($cloudServiceName, $serverName, $instanceSize)
{
    New-AzureVMConfig `
        -Name $serverName `
        -InstanceSize $instanceSize `
        -ImageName $linuxImageName `
        -MediaLocation "$storageAccountContainer$serverName.vhd" `
        -AvailabilitySetName $azureAvailabilitySetName `
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