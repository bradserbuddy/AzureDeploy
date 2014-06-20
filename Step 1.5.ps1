Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

. $workingDir"Common\RunRemotely.ps1"


Write-Status "Installing Sql Failover Clustering..."
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sqlServerName1
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlServerAdminUserName, $sqlServerAdminPassword
Remove-PSSession -Session $session
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sqlServerName2
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlServerAdminUserName, $sqlServerAdminPassword
Remove-PSSession -Session $session


Write-Status "Done!"