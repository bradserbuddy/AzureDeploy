function AddDbToAvailabilityGroup($databaseName)
{
    $backupShare = "\\$sql1ServerName\backup"
    $quorumShare = "\\$sql1ServerName\quorum"


    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking
    
 
    $sqlServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "."
    $database = $sqlServer.Databases[$databaseName]
    $database.RecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Full;
    $database.AutoClose = $false;
    $database.Alter();


    Backup-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.bak" -ServerInstance $sql1ServerName
    Backup-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.log" -ServerInstance $sql1ServerName -BackupAction Log
    Restore-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.bak" -ServerInstance $sql2ServerName -NoRecovery
    Restore-SqlDatabase -Database $databaseName -BackupFile "$backupShare\$databaseName.log" -ServerInstance $sql2ServerName -RestoreAction Log -NoRecovery 


    Add-SqlAvailabilityDatabase `
        -Path "SQLSERVER:\SQL\$sql1ServerName\Default\AvailabilityGroups\$sqlAvailabilityGroupName" `
        -Database $databaseName
    Add-SqlAvailabilityDatabase `
        -Path "SQLSERVER:\SQL\$sql2ServerName\Default\AvailabilityGroups\$sqlAvailabilityGroupName" `
        -Database $databaseName
}