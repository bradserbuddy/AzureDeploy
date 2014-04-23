function ConfigureDc()
{
    $scriptBlock =
    {
        Install-WindowsFeature -name AD-Domain-Services –IncludeManagementTools

        $securePassword = ConvertTo-SecureString -AsPlainText $Using:vmAdminPassword -Force

        Install-ADDSForest –DomainName $Using:FQDN `
                            -SafeModeAdministratorPassword $securePassword `
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

    Restart-AzureVM -ServiceName $dcCloudServiceName -Name $dcServerName

    . $workingDir"Dc\AddDcUsers.ps1"
    AddDCUsers

    . $workingDir"Dc\ConfigureDcPermissions.ps1"
    ConfigureDcPermissions
}