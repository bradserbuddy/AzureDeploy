Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

. $workingDir"Common\RunRemotely.ps1"


Write-Host "Adding Virtual Network..."
. $workingDir"Add-VirtualNetworkSite.ps1"
Add-VirtualNetworkSite $virtualNetworkName $affinityGroupName "10.10.0.0/16" "10.10.1.0/24" "10.10.2.0/24"


Write-Host "Creating Dc..."
. $workingDir"Dc\CreateDc.ps1"
CreateDc


Write-Host "Configuring Dc..."
. $workingDir"Dc\ConfigureDc.ps1"
ConfigureDc


Write-Host "Creating Web..."
. $workingDir"Web\CreateWeb.ps1"
CreateWeb


Write-Host "Setting Web Endpoints..."
. $workingDir"Web\SetWebEndpoints.ps1"


Write-Host "Create Mongo..."
. $workingDir"Mongo\CreateMongo.ps1"
CreateMongo


Write-Host "Creating Quorum..."
. $workingDir"Quorum\CreateQuorum.ps1"
CreateQuorum


Write-Host "Setting SSH Endpoints..."
. $workingDir"Common\SetSSHEndpoints.ps1"


Write-Host "Installing Quorum Failover Clustering..."
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $quorumServerName
Invoke-Command -Session $session -FilePath $workingDir"Quorum\InstallQuorumFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName
Remove-PSSession -Session $session


Write-Host "Creating Sql..."
. $workingDir"Sql\CreateSql.ps1"
CreateSql


Write-Host "Installing Sql Failover Clustering..."
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sql1ServerName
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlPassword
Remove-PSSession -Session $session
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sql2ServerName
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlPassword
Remove-PSSession -Session $session


Write-Host "Done!"