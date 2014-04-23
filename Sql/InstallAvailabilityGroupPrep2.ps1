param($sql2ServerName, $sqlUserName2, $vmAdminPassword)

function InstallAvailabilityGroupPrep2()
{
    $timeout = New-Object System.TimeSpan -ArgumentList 0, 0, 30

    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking

    $wmi2 = new-object ("Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer") $sql2ServerName
    $wmi2.services | where {$_.Type -eq 'SqlServer'} | foreach{$_.SetServiceAccount($sqlUserName2,$vmAdminPassword)}
    $svc2 = Get-Service -ComputerName $sql2ServerName -Name 'MSSQLSERVER'
    $svc2.Stop()
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Stopped,$timeout)
    $svc2.Start(); 
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running,$timeout)
}

InstallAvailabilityGroupPrep2