function InstallAvailabilityGroup()
{
    $timeout = New-Object System.TimeSpan -ArgumentList 0, 0, 30

    Set-ExecutionPolicy RemoteSigned -Force
    Import-Module "sqlps" -DisableNameChecking
    
    Enable-SqlAlwaysOn `
        -Path SQLSERVER:\SQL\$sql1ServerName\Default `
        -Force
    Enable-SqlAlwaysOn `
        -Path SQLSERVER:\SQL\$sql2ServerName\Default `
        -NoServiceRestart
    $svc2 = Get-Service -ComputerName $sql2ServerName -Name 'MSSQLSERVER'
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