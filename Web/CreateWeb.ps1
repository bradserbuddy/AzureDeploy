function CreateWeb($workingDir)
{
    # Missing -> Add-AzureDataDisk adds the data disk that you will use for storing Active Directory data, with caching option set to None.

    $winImageName = (Get-AzureVMImage | where {$_.Label -like "Windows Server 2012 R2 Datacenter*"} | sort PublishedDate -Descending)[0].ImageName

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $webServerName1

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $webServerName1 `
            -InstanceSize Medium `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$webServerName1.vhd" `
            -AvailabilitySetName $azureAvailabilitySetName `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Windows `
                -DisableAutomaticUpdates `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword |
                Set-AzureSubnet `
                    -SubnetNames $frontSubnetName |
					New-AzureVM `
						-ServiceName $dcCloudServiceName

        . $workingDir"\Common\WaitForVM.ps1"
        WaitAndDownloadRDF-ForVM $dcCloudServiceName $webServerName1

		#$credential = New-Object System.Management.Automation.PSCredential($vmAdminUser, $(ConvertTo-SecureString $vmAdminPassword -AsPlainText -Force))
		#Enable-RemotePsRemoting $dcServerName $credential
	
		#Invoke-Command -ComputerName $dcServerName –ScriptBlock { dcpromo.exe /unattend /ReplicaOrNewDomain:Domain /NewDomain:Forest /NewDomainDNSName:$FQDN /ForestLevel:4 /DomainNetbiosName:$domainName /DomainLevel:4 /InstallDNS:Yes /ConfirmGc:Yes /CreateDNSDelegation:No /DatabasePath:"C:\Windows\NTDS" /LogPath:"C:\Windows\NTDS" /SYSVOLPath:"C:\Windows\SYSVOL" /SafeModeAdminPassword:$vmAdminPassword }
    }

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $webServerName2

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $webServerName2 `
            -InstanceSize Medium `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$webServerName2.vhd" `
            -AvailabilitySetName $azureAvailabilitySetName `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Windows `
                -DisableAutomaticUpdates `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword |
                Set-AzureSubnet `
                    -SubnetNames $frontSubnetName |
					New-AzureVM `
						-ServiceName $dcCloudServiceName

        . $workingDir"\Common\WaitForVM.ps1"
        WaitAndDownloadRDF-ForVM $dcCloudServiceName $webServerName2

		#$credential = New-Object System.Management.Automation.PSCredential($vmAdminUser, $(ConvertTo-SecureString $vmAdminPassword -AsPlainText -Force))
		#Enable-RemotePsRemoting $dcServerName $credential
	
		#Invoke-Command -ComputerName $dcServerName –ScriptBlock { dcpromo.exe /unattend /ReplicaOrNewDomain:Domain /NewDomain:Forest /NewDomainDNSName:$FQDN /ForestLevel:4 /DomainNetbiosName:$domainName /DomainLevel:4 /InstallDNS:Yes /ConfirmGc:Yes /CreateDNSDelegation:No /DatabasePath:"C:\Windows\NTDS" /LogPath:"C:\Windows\NTDS" /SYSVOLPath:"C:\Windows\SYSVOL" /SafeModeAdminPassword:$vmAdminPassword }
    }
}