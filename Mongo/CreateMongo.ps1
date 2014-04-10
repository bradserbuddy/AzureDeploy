#TODO: add mongodb to mongo boxes, add user\password


function CreateMongo($workingDir)
{
    # Missing -> Add-AzureDataDisk adds the data disk that you will use for storing Active Directory data, with caching option set to None.

    $linuxImageName = (Get-AzureVMImage | where {$_.Label -like "Ubuntu Server 12.04.4 LTS"} | sort PublishedDate -Descending)[0].ImageName

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $mongoServerName1

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $mongoServerName1 `
            -InstanceSize Large `
            -ImageName $linuxImageName `
            -MediaLocation "$storageAccountContainer$mongoServerName1.vhd" `
            -AvailabilitySetName $azureAvailabilitySetName `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Linux `
                -LinuxUser $vmAdminUser `
                -Password $vmAdminPassword |
                Set-AzureSubnet `
                    -SubnetNames $frontSubnetName |
					New-AzureVM `
						-ServiceName $dcCloudServiceName

        . $workingDir"\Common\WaitForVM.ps1"
        Wait-ForVM $dcCloudServiceName $mongoServerName1

		#$credential = New-Object System.Management.Automation.PSCredential($vmAdminUser, $(ConvertTo-SecureString $vmAdminPassword -AsPlainText -Force))
		#Enable-RemotePsRemoting $dcServerName $credential
	
		#Invoke-Command -ComputerName $dcServerName –ScriptBlock { dcpromo.exe /unattend /ReplicaOrNewDomain:Domain /NewDomain:Forest /NewDomainDNSName:$FQDN /ForestLevel:4 /DomainNetbiosName:$domainName /DomainLevel:4 /InstallDNS:Yes /ConfirmGc:Yes /CreateDNSDelegation:No /DatabasePath:"C:\Windows\NTDS" /LogPath:"C:\Windows\NTDS" /SYSVOLPath:"C:\Windows\SYSVOL" /SafeModeAdminPassword:$vmAdminPassword }
    }

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $mongoServerName2

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $mongoServerName2 `
            -InstanceSize Large `
            -ImageName $linuxImageName `
            -MediaLocation "$storageAccountContainer$mongoServerName2.vhd" `
            -AvailabilitySetName $azureAvailabilitySetName `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Linux `
                -LinuxUser $vmAdminUser `
                -Password $vmAdminPassword |
                Set-AzureSubnet `
                    -SubnetNames $frontSubnetName |
					New-AzureVM `
						-ServiceName $dcCloudServiceName

        . $workingDir"\Common\WaitForVM.ps1"
        Wait-ForVM $dcCloudServiceName $mongoServerName2

		#$credential = New-Object System.Management.Automation.PSCredential($vmAdminUser, $(ConvertTo-SecureString $vmAdminPassword -AsPlainText -Force))
		#Enable-RemotePsRemoting $dcServerName $credential
	
		#Invoke-Command -ComputerName $dcServerName –ScriptBlock { dcpromo.exe /unattend /ReplicaOrNewDomain:Domain /NewDomain:Forest /NewDomainDNSName:$FQDN /ForestLevel:4 /DomainNetbiosName:$domainName /DomainLevel:4 /InstallDNS:Yes /ConfirmGc:Yes /CreateDNSDelegation:No /DatabasePath:"C:\Windows\NTDS" /LogPath:"C:\Windows\NTDS" /SYSVOLPath:"C:\Windows\SYSVOL" /SafeModeAdminPassword:$vmAdminPassword }
    }
}