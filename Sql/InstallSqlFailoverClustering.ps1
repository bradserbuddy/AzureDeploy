function InstallSqlFailoverClustering()
{
    Import-Module ServerManager
    Add-WindowsFeature Failover-Clustering

    net localgroup administrators $domainNameAsPrefix$installUserName /Add

    Set-ExecutionPolicy -Execution RemoteSigned -Force
    Import-Module -Name "sqlps" -DisableNameChecking

    Invoke-SqlCmd -Query "EXEC sp_addsrvrolemember '$domainNameAsPrefix$installUserName', $vmAdminUser" -ServerInstance "." -Username "sa" -Password $sqlPassword

    # already on SQLImage Invoke-SqlCmd -Query "CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS" -ServerInstance "." -Username "sa" -Password $sqlPassword
    Invoke-SqlCmd -Query "GRANT ALTER ANY AVAILABILITY GROUP TO [NT AUTHORITY\SYSTEM] AS SA" -ServerInstance "." -Username "sa" -Password $sqlPassword
    Invoke-SqlCmd -Query "GRANT CONNECT SQL TO [NT AUTHORITY\SYSTEM] AS SA" -ServerInstance "." -Username "sa" -Password $sqlPassword
    Invoke-SqlCmd -Query "GRANT VIEW SERVER STATE TO [NT AUTHORITY\SYSTEM] AS SA" -ServerInstance "." -Username "sa" -Password $sqlPassword

    netsh advfirewall firewall add rule name='SQL Server (TCP-In)' program='C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Binn\sqlservr.exe' dir=in action=allow protocol=TCP

    logoff.exe
}
