param($sql1ServerName, $sqlUserName1, $sql2ServerName, $sqlUserName2, $vmAdminPassword)

function InstallAvailabilityGroupPrep($sqlServerName, $sqlUserName, $vmAdminPassword)
{
    $timeout = New-Object System.TimeSpan -ArgumentList 0, 0, 30

    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking

    $wmi = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $sqlServerName
    $wmi.services | where {$_.Type -eq 'SqlServer'} | foreach{$_.SetServiceAccount($sqlUserName,$vmAdminPassword)}
    $svc = Get-Service -ComputerName $sqlServerName -Name 'MSSQLSERVER'
    $svc.Stop()
    $svc.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Stopped,$timeout)
    $svc.Start(); 
    $svc.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running,$timeout)
}

InstallAvailabilityGroupPrep $sql1ServerName, $sqlUserName1, $vmAdminPassword
InstallAvailabilityGroupPrep $sql2ServerName, $sqlUserName2, $vmAdminPassword