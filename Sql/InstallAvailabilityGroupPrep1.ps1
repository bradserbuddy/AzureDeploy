param($sql1ServerName, $sqlUserName1, $vmAdminPassword)

function InstallAvailabilityGroupPrep1()
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
}

InstallAvailabilityGroupPrep1