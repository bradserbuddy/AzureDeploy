function AddDbToAvailabilityGroup($databaseName)
{
    $backupShare = "\\$sql1ServerName\backup"
    $quorumShare = "\\$sql1ServerName\quorum"


    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking

     
    $backupName = "backup"
    $backup = Get-SMBShare $backupName
    if ($backup -eq $null)
    {
        New-SMBShare -Name $backupName -Path "c:\backup" -FullAccess $sqlUserName1, $sqlUserName2
    }
    icacls.exe $backup.Path /grant:r ("$sqlUserName1" + ":(OI)(CI)F") ("$sqlUserName2" + ":(OI)(CI)F") 
    
 
    $sqlServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "."
    $database = $sqlServer.Databases[$databaseName]
    $database.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Full;
    $database.AutoClose = $false;
    $database.Alter();


    Backup-SqlDatabase -Database $databaseName -BackupFile "$backupShare\db.bak" -ServerInstance $sql1ServerName
    Backup-SqlDatabase -Database $databaseName -BackupFile "$backupShare\db.log" -ServerInstance $sql1ServerName -BackupAction Log
    Restore-SqlDatabase -Database $databaseName -BackupFile "$backupShare\db.bak" -ServerInstance $sql2ServerName -NoRecovery
    Restore-SqlDatabase -Database $databaseName -BackupFile "$backupShare\db.log" -ServerInstance $sql2ServerName -RestoreAction Log -NoRecovery 


    $primaryReplica = 
        New-SqlAvailabilityReplica `
        -Name $sql1ServerName `
        -EndpointUrl "TCP://$sql1ServerName.$($FQDN):5022" `
        -AvailabilityMode "SynchronousCommit" `
        -FailoverMode "Automatic" `
        -Version 11 `
        -AsTemplate
    $secondaryReplica = 
        New-SqlAvailabilityReplica `
        -Name $sql2ServerName `
        -EndpointUrl "TCP://$sql2ServerName.$($FQDN):5022" `
        -AvailabilityMode "SynchronousCommit" `
        -FailoverMode "Automatic" `
        -Version 11 `
        -AsTemplate 


    New-SqlAvailabilityGroup `
        -Name $sqlAvailabilityGroupName `
        -Path "SQLSERVER:\SQL\$sql1ServerName\Default" `
        -AvailabilityReplica @($primaryReplica,$secondaryReplica) `
        -Database $databaseName
    Join-SqlAvailabilityGroup `
        -Path "SQLSERVER:\SQL\$sql2ServerName\Default" `
        -Name $sqlAvailabilityGroupName
    Add-SqlAvailabilityDatabase `
        -Path "SQLSERVER:\SQL\$sql2ServerName\Default\AvailabilityGroups\$sqlAvailabilityGroupName" `
        -Database $databaseName
}