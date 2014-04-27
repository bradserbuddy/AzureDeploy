Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

. $workingDir"Common\RunRemotely.ps1"


Write-Status "Installing Sql Failover Clustering..."
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sql1ServerName
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlPassword
Remove-PSSession -Session $session
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sql2ServerName
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlPassword
Remove-PSSession -Session $session


Write-Status "Done!"