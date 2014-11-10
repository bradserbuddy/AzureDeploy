function ConfigureDc()
{
    Write-Status "Log on to $dcServerName, then hit Enter."
    Read-Host

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
                            -Force
    }

    Write-Status "Verify $dcServerName reboots successfully after AD installation, then hit Enter."

    RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $dcServerName $scriptBlock

    Read-Host

    . $workingDir"Dc\AddDcUsers.ps1"
    AddDCUsers

    . $workingDir"Dc\ConfigureDcPermissions.ps1"
    ConfigureDcPermissions
}