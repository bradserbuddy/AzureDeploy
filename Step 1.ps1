Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

. $workingDir"Common\RunRemotely.ps1"


echo "Adding Virtual Network..."
. $workingDir"Add-VirtualNetworkSite.ps1"
Add-VirtualNetworkSite $virtualNetworkName $affinityGroupName "10.10.0.0/16" "10.10.1.0/24" "10.10.2.0/24"


echo "Creating Dc..."
. $workingDir"Dc\CreateDc.ps1"
CreateDc


echo "Configuring Dc..."
. $workingDir"Dc\ConfigureDc.ps1"
ConfigureDc


echo "Creating Web..."
. $workingDir"Web\CreateWeb.ps1"
CreateWeb


echo "Setting Web Endpoints..."
. $workingDir"Web\SetWebEndpoints.ps1"


. $workingDir"Mongo\CreateMongo.ps1"
CreateMongo


echo "Creating Quorum..."
. $workingDir"Quorum\CreateQuorum.ps1"
CreateQuorum


echo "Installing Quorum Failover Clustering..."
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $quorumServerName
Invoke-Command -Session $session -FilePath $workingDir"Quorum\InstallQuorumFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName
Remove-PSSession -Session $session


echo "Creating Sql..."
. $workingDir"Sql\CreateSql.ps1"
CreateSql


echo "Installing Sql Failover Clustering..."
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sql1ServerName
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlPassword
Remove-PSSession -Session $session
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sql2ServerName
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlPassword
Remove-PSSession -Session $session


echo "Install Availability Group Prep..."
$session = GetSession "$domainNameAsPrefix$installUserName" $vmAdminPassword $sqlCloudServiceName $sql1ServerName
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallAvailabilityGroupPrep.ps1" -ArgumentList $sql1ServerName, $sqlUserName1, $sql2ServerName, $sqlUserName2, $vmAdminPassword
Remove-PSSession -Session $session


echo "Done!"