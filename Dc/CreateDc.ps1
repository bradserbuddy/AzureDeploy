function CreateDc($workingDir)
{
    # Missing -> Add-AzureDataDisk adds the data disk that you will use for storing Active Directory data, with caching option set to None.

    $winImageName = (Get-AzureVMImage | where {$_.Label -like "Windows Server 2012 R2 Datacenter*"} | sort PublishedDate -Descending)[0].ImageName

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $dcServerName

    if ($vm -eq $null)
    {
        New-AzureVMConfig `
            -Name $dcServerName `
            -InstanceSize Medium `
            -ImageName $winImageName `
            -MediaLocation "$storageAccountContainer$dcServerName.vhd" `
            -DiskLabel "OS" | 
            Add-AzureProvisioningConfig `
                -Windows `
                -DisableAutomaticUpdates `
                -AdminUserName $vmAdminUser `
                -Password $vmAdminPassword |
                New-AzureVM `
                    -ServiceName $dcCloudServiceName `
                    –AffinityGroup $affinityGroupName `
                    -VNetName $virtualNetworkName

        . $workingDir"\Common\WaitForVM.ps1"
        WaitAndDownloadRDF-ForVM $dcCloudServiceName $dcServerName

		#$credential = New-Object System.Management.Automation.PSCredential($vmAdminUser, $(ConvertTo-SecureString $vmAdminPassword -AsPlainText -Force))
		#Enable-RemotePsRemoting $dcServerName $credential
	
		#Invoke-Command -ComputerName $dcServerName –ScriptBlock { dcpromo.exe /unattend /ReplicaOrNewDomain:Domain /NewDomain:Forest /NewDomainDNSName:$FQDN /ForestLevel:4 /DomainNetbiosName:$domainName /DomainLevel:4 /InstallDNS:Yes /ConfirmGc:Yes /CreateDNSDelegation:No /DatabasePath:"C:\Windows\NTDS" /LogPath:"C:\Windows\NTDS" /SYSVOLPath:"C:\Windows\SYSVOL" /SafeModeAdminPassword:$vmAdminPassword }
    }
}