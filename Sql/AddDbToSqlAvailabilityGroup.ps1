function AddDbToSqlAvailabilityGroup($databaseName)
{
    $backupShare = "\\$sqlServerName1\backup"
    $quorumShare = "\\$sqlServerName1\quorum"


    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking
    
 
    $sqlServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "."
    $database = $sqlServer.Databases[$databaseName]
    $database.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Full;
    $database.AutoClose = $false;
    $database.Alter();


    Backup-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.bak" -ServerInstance $sqlServerName1
    Backup-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.log" -ServerInstance $sqlServerName1 -BackupAction Log
    Restore-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.bak" -ServerInstance $sqlServerName2 -NoRecovery
    Restore-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.log" -ServerInstance $sqlServerName2 -RestoreAction Log -NoRecovery 


    Add-SqlAvailabilityDatabase `
        -Path "SQLSERVER:\SQL\$sqlServerName1\Default\AvailabilityGroups\$sqlAvailabilityGroupName" `
        -Database $databaseName
    Add-SqlAvailabilityDatabase `
        -Path "SQLSERVER:\SQL\$sqlServerName2\Default\AvailabilityGroups\$sqlAvailabilityGroupName" `
        -Database $databaseName
}