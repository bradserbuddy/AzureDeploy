﻿param($domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlServerAdminUserName, $sqlServerAdminPassword)

function InstallSqlFailoverClustering()
{
    Import-Module ServerManager
    Add-WindowsFeature Failover-Clustering

    $fullInstallUserName = "$domainNameAsPrefix$installUserName"

    net localgroup administrators $fullInstallUserName /Add  # System error 1378 has occurred. - check to see if the user has already added

    Set-ExecutionPolicy -Execution RemoteSigned -Force
    Import-Module -Name "sqlps" -DisableNameChecking

    Invoke-SqlCmd -Query "EXEC sp_addsrvrolemember '$fullInstallUserName', $vmAdminUser" -ServerInstance "." -Username $sqlServerAdminUserName -Password $sqlServerAdminPassword

    # already on SQLImage Invoke-SqlCmd -Query "CREATE LOGIN [NT AUTHORITY\SYSTEM] FROM WINDOWS" -ServerInstance "." -Username $sqlServerAdminUserName -Password $sqlPassword
    Invoke-SqlCmd -Query "GRANT ALTER ANY AVAILABILITY GROUP TO [NT AUTHORITY\SYSTEM] AS SA" -ServerInstance "." -Username $sqlServerAdminUserName -Password $sqlServerAdminPassword
    Invoke-SqlCmd -Query "GRANT CONNECT SQL TO [NT AUTHORITY\SYSTEM] AS SA" -ServerInstance "." -Username $sqlServerAdminUserName -Password $sqlServerAdminPassword
    Invoke-SqlCmd -Query "GRANT VIEW SERVER STATE TO [NT AUTHORITY\SYSTEM] AS SA" -ServerInstance "." -Username $sqlServerAdminUserName -Password $sqlServerAdminPassword

    netsh advfirewall firewall add rule name='SQL Server (TCP-In)' program='C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Binn\sqlservr.exe' dir=in action=allow protocol=TCP
}

InstallSqlFailoverClustering