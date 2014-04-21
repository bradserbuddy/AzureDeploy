function ConfigureDc()
{
    $scriptBlock =
    {
        Install-WindowsFeature -name AD-Domain-Services –IncludeManagementTools

        Install-ADDSForest –DomainName $Using:FQDN `
                            -SafeModeAdministratorPassword $Using:vmAdminPassword `
                            -CreateDNSDelegation:$false `
                            -DatabasePath "C:\Windows\NTDS" `
                            -DomainMode Win2012 `
                            -DomainNetBIOSName $Using:domainName `
                            -ForestMode Win2012 `
                            -LogPath "C:\Windows\NTDS" `
                            -SYSVOLPath "C:\Windows\SYSVOL" `
                            -NoRebootOnCompletion
        
    }

    RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $dcServerName $scriptBlock

    Reboot-AzureVM -ServiceName $dcCloudServiceName -Name $dcServerName

    . $workingDir"Dc\AddDcUsers.ps1"
    AddDCUsers

    . $workingDir"Dc\ConfigureDcPermissions.ps1"
    ConfigureDcPermissions
}