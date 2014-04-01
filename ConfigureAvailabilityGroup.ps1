function ConfigureAvailabilityGroup($workingDir)
{
    $acct1 = "$domainNameAsPrefix$sqlDcUserName1"
    $acct2 = "$domainNameAsPrefix$sqlDcUserName2"
    $clusterName = "ClusterSeasia"
    $timeout = New-Object System.TimeSpan -ArgumentList 0, 0, 30
    $db = "MyDB1"
    $backupShare = "\\$sql1ServerName\backup"
    $quorumShare = "\\$sql1ServerName\quorum"
    $ag = "AG1" 


    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking


    $wmi1 = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $sql1ServerName
    $wmi1.services | where {$_.Type -eq 'SqlServer'} | foreach{$_.SetServiceAccount($acct1,$vmAdminPassword)}
    $svc1 = Get-Service -ComputerName $sql1ServerName -Name 'MSSQLSERVER'
    $svc1.Stop()
    $svc1.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Stopped,$timeout)
    $svc1.Start(); 
    $svc1.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running,$timeout)


    $wmi2 = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $sql2ServerName
    $wmi2.services | where {$_.Type -eq 'SqlServer'} | foreach{$_.SetServiceAccount($acct2,$vmAdminPassword)}
    $svc2 = Get-Service -ComputerName $sql2ServerName -Name 'MSSQLSERVER'
    $svc2.Stop()
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Stopped,$timeout)
    $svc2.Start(); 
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running,$timeout)


    Add-WindowsFeature 'Failover-Clustering', 'RSAT-Clustering-PowerShell', 'RSAT-Clustering-CmdInterface'


    Set-ExecutionPolicy Unrestricted -Force
    $createAzureFailoverClusterScript = $workingDir + "CreateAzureFailoverCluster.ps1"
    & $createAzureFailoverClusterScript -ClusterName "$clusterName" -ClusterNode "$sql1ServerName","$sql2ServerName","$quorumServerName"

    Enable-SqlAlwaysOn `
        -Path SQLSERVER:\SQL\$sql1ServerName\Default `
        -Force
    Enable-SqlAlwaysOn `
        -Path SQLSERVER:\SQL\$sql2ServerName\Default `
        -NoServiceRestart
    $svc2.Stop()
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Stopped,$timeout)
    $svc2.Start(); 
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running,$timeout)


    $backup = "C:\backup"
    New-Item $backup -ItemType directory
    net share backup=$backup "/grant:$acct1,FULL" "/grant:$acct2,FULL"
    icacls.exe "$backup" /grant:r ("$acct1" + ":(OI)(CI)F") ("$acct2" + ":(OI)(CI)F") 


    Invoke-SqlCmd -Query "CREATE database $db"
    Backup-SqlDatabase -Database $db -BackupFile "$backupShare\db.bak" -ServerInstance $sql1ServerName
    Backup-SqlDatabase -Database $db -BackupFile "$backupShare\db.log" -ServerInstance $sql1ServerName -BackupAction Log
    Restore-SqlDatabase -Database $db -BackupFile "$backupShare\db.bak" -ServerInstance $sql2ServerName -NoRecovery
    Restore-SqlDatabase -Database $db -BackupFile "$backupShare\db.log" -ServerInstance $sql2ServerName -RestoreAction Log -NoRecovery 


    $endpoint = 
        New-SqlHadrEndpoint MyMirroringEndpoint `
        -Port 5022 `
        -Path "SQLSERVER:\SQL\$sql1ServerName\Default"
    Set-SqlHadrEndpoint `
        -InputObject $endpoint `
        -State "Started"
    $endpoint = 
        New-SqlHadrEndpoint MyMirroringEndpoint `
        -Port 5022 `
        -Path "SQLSERVER:\SQL\$sql2ServerName\Default"
    Set-SqlHadrEndpoint `
        -InputObject $endpoint `
        -State "Started"

    Invoke-SqlCmd -Query "CREATE LOGIN [$acct2] FROM WINDOWS" -ServerInstance $sql1ServerName
    Invoke-SqlCmd -Query "GRANT CONNECT ON ENDPOINT::[MyMirroringEndpoint] TO [$acct2]" -ServerInstance $sql1ServerName
    Invoke-SqlCmd -Query "CREATE LOGIN [$acct1] FROM WINDOWS" -ServerInstance $sql2ServerName
    Invoke-SqlCmd -Query "GRANT CONNECT ON ENDPOINT::[MyMirroringEndpoint] TO [$acct1]" -ServerInstance $sql2ServerName 


    $primaryReplica = 
        New-SqlAvailabilityReplica `
        -Name $sql1ServerName `
        -EndpointUrl "TCP://$sql1ServerName.$FQDN:5022" `
        -AvailabilityMode "SynchronousCommit" `
        -FailoverMode "Automatic" `
        -Version 11 `
        -AsTemplate
    $secondaryReplica = 
        New-SqlAvailabilityReplica `
        -Name $sql2ServerName `
        -EndpointUrl "TCP://$sql2ServerName.$FQDN:5022" `
        -AvailabilityMode "SynchronousCommit" `
        -FailoverMode "Automatic" `
        -Version 11 `
        -AsTemplate 


    New-SqlAvailabilityGroup `
        -Name $ag `
        -Path "SQLSERVER:\SQL\$sql1ServerName\Default" `
        -AvailabilityReplica @($primaryReplica,$secondaryReplica) `
        -Database $db
    Join-SqlAvailabilityGroup `
        -Path "SQLSERVER:\SQL\$sql2ServerName\Default" `
        -Name $ag
    Add-SqlAvailabilityDatabase `
        -Path "SQLSERVER:\SQL\$sql2ServerName\Default\AvailabilityGroups\$ag" `
        -Database $db
}