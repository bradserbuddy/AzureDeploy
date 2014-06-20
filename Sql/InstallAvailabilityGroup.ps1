function InstallAvailabilityGroup()
{
    $timeout = New-Object System.TimeSpan -ArgumentList 0, 0, 30

    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking
    
    Enable-SqlAlwaysOn `
        -Path SQLSERVER:\SQL\$sqlServerName1\Default `
        -Force
    Enable-SqlAlwaysOn `
        -Path SQLSERVER:\SQL\$sqlServerName2\Default `
        -NoServiceRestart
    $svc2 = Get-Service -ComputerName $sqlServerName2 -Name 'MSSQLSERVER'
    $svc2.Stop()
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Stopped,$timeout)
    $svc2.Start(); 
    $svc2.WaitForStatus([System.ServiceProcess.ServiceControllerStatus]::Running,$timeout)


    $endpoint = 
        New-SqlHadrEndpoint MyMirroringEndpoint `
        -Port 5022 `
        -Path "SQLSERVER:\SQL\$sqlServerName1\Default"
    Set-SqlHadrEndpoint `
        -InputObject $endpoint `
        -State "Started"
    $endpoint = 
        New-SqlHadrEndpoint MyMirroringEndpoint `
        -Port 5022 `
        -Path "SQLSERVER:\SQL\$sqlServerName2\Default"
    Set-SqlHadrEndpoint `
        -InputObject $endpoint `
        -State "Started"


    Invoke-SqlCmd -Query "CREATE LOGIN [$sqlUserName2] FROM WINDOWS" -ServerInstance $sqlServerName1
    Invoke-SqlCmd -Query "GRANT CONNECT ON ENDPOINT::[MyMirroringEndpoint] TO [$sqlUserName2]" -ServerInstance $sqlServerName1
    Invoke-SqlCmd -Query "CREATE LOGIN [$sqlUserName1] FROM WINDOWS" -ServerInstance $sqlServerName2
    Invoke-SqlCmd -Query "GRANT CONNECT ON ENDPOINT::[MyMirroringEndpoint] TO [$sqlUserName1]" -ServerInstance $sqlServerName2 
}