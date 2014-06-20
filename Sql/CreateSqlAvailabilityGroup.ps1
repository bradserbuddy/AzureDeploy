function CreateSqlAvailabilityGroup($databaseName)
{
    $backupShare = "\\$sqlServerName1\backup"
    $quorumShare = "\\$sqlServerName1\quorum"


    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking



    $backup = "C:\backup"
    New-Item $backup -ItemType directory
    net share backup=$backup "/grant:$sqlUserName1,FULL" "/grant:$sqlUserName2,FULL"   
    icacls.exe $backup /grant:r ("$sqlUserName1" + ":(OI)(CI)F") ("$sqlUserName2" + ":(OI)(CI)F") 

    <# TODO: SmbShare doesn't work in the PowerShell ISE
    $backupName = "backup"
    $backup = $null
    try { $backup = Get-SmbShare $backupName } catch { }
    if ($backup -eq $null)
    {
        New-SmbShare -Name $backupName -Path "c:\backup" -FullAccess $sqlUserName1, $sqlUserName2
    }
    icacls.exe $backup.Path /grant:r ("$sqlUserName1" + ":(OI)(CI)F") ("$sqlUserName2" + ":(OI)(CI)F")#> 
    
 
    $sqlServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "."
    $database = $sqlServer.Databases[$databaseName]
    $database.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Full;
    $database.AutoClose = $false;
    $database.Alter();


    Backup-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.bak" -ServerInstance $sqlServerName1
    Backup-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.log" -ServerInstance $sqlServerName1 -BackupAction Log
    Restore-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.bak" -ServerInstance $sqlServerName2 -NoRecovery
    Restore-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.log" -ServerInstance $sqlServerName2 -RestoreAction Log -NoRecovery 


    $primaryReplica = 
        New-SqlAvailabilityReplica `
        -Name $sqlServerName1 `
        -EndpointUrl "TCP://$sqlServerName1.$($FQDN):5022" `
        -AvailabilityMode "SynchronousCommit" `
        -FailoverMode "Automatic" `
        -Version 11 `
        -AsTemplate
    $secondaryReplica = 
        New-SqlAvailabilityReplica `
        -Name $sqlServerName2 `
        -EndpointUrl "TCP://$sqlServerName2.$($FQDN):5022" `
        -AvailabilityMode "SynchronousCommit" `
        -FailoverMode "Automatic" `
        -Version 11 `
        -AsTemplate 


    New-SqlAvailabilityGroup `
        -Name $sqlAvailabilityGroupName `
        -Path "SQLSERVER:\SQL\$sqlServerName1\Default" `
        -AvailabilityReplica @($primaryReplica,$secondaryReplica) `
        -Database $databaseName
    Join-SqlAvailabilityGroup `
        -Path "SQLSERVER:\SQL\$sqlServerName2\Default" `
        -Name $sqlAvailabilityGroupName


    Add-SqlAvailabilityDatabase `
        -Path "SQLSERVER:\SQL\$sqlServerName2\Default\AvailabilityGroups\$sqlAvailabilityGroupName" `
        -Database $databaseName
}