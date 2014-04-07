function ConfigureAvailabilityGroup($workingDir)
{
    $timeout = New-Object System.TimeSpan -ArgumentList 0, 0, 30


    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking


    $wmi1 = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $sql1ServerName
    $wmi1.services | where {$_.Type -eq 'SqlServer'} | foreach{$_.SetServiceAccount($sqlUserName1,$vmAdminPassword)}
    $svc1 = Get-Service -ComputerName $sql1ServerName -Name 'MSSQLSERVER'
    $svc1.Stop()
    $svc1.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Stopped,$timeout)
    $svc1.Start(); 
    $svc1.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running,$timeout)


    $wmi2 = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $sql2ServerName
    $wmi2.services | where {$_.Type -eq 'SqlServer'} | foreach{$_.SetServiceAccount($sqlUserName2,$vmAdminPassword)}
    $svc2 = Get-Service -ComputerName $sql2ServerName -Name 'MSSQLSERVER'
    $svc2.Stop()
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Stopped,$timeout)
    $svc2.Start(); 
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running,$timeout)


    Add-WindowsFeature 'Failover-Clustering', 'RSAT-Clustering-PowerShell', 'RSAT-Clustering-CmdInterface'


    Set-ExecutionPolicy Unrestricted -Force
    $createAzureFailoverClusterScript = $workingDir + "External\CreateAzureFailoverCluster.ps1"
    & $createAzureFailoverClusterScript -ClusterName "$sqlClusterName" -ClusterNode "$sql1ServerName","$sql2ServerName","$quorumServerName" -Force


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


    Invoke-SqlCmd -Query "CREATE LOGIN [$sqlUserName2] FROM WINDOWS" -ServerInstance $sql1ServerName
    Invoke-SqlCmd -Query "GRANT CONNECT ON ENDPOINT::[MyMirroringEndpoint] TO [$sqlUserName2]" -ServerInstance $sql1ServerName
    Invoke-SqlCmd -Query "CREATE LOGIN [$sqlUserName1] FROM WINDOWS" -ServerInstance $sql2ServerName
    Invoke-SqlCmd -Query "GRANT CONNECT ON ENDPOINT::[MyMirroringEndpoint] TO [$sqlUserName1]" -ServerInstance $sql2ServerName 
}