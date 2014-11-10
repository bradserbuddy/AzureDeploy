Import-Module "C:\Program Files (x86)\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

. $workingDir"Common\RunRemotely.ps1"
. $workingDir"Common\CreateVm.ps1"
. $workingDir"Common\RdpManageCert.ps1"


Write-Status "Adding Virtual Network..."
. $workingDir"Add-VirtualNetworkSite.ps1"
Add-VirtualNetworkSite $virtualNetworkName $affinityGroupName "10.10.0.0/16" "10.10.1.0/24" "10.10.2.0/24"


# CreateDc creates the DC web service, so has to be first
Write-Status "Creating Dc (Services 1)..."
. $workingDir"Dc\CreateDc.ps1"
CreateDc

Write-Status "Configuring Dc..."
. $workingDir"Dc\ConfigureDc.ps1"
ConfigureDc


Write-Status "Creating Services 2..."
CreateServices2


. $workingDir"Web\CreateWeb.ps1"
CreateWeb


Write-Status "Setting Web Endpoints..."
. $workingDir"Web\SetWebEndpoints.ps1"


. $workingDir"Memcached\CreateMemcached.ps1"
CreateMemcached


. $workingDir"Mongo\CreateMongo.ps1"
CreateMongo


. $workingDir"Common\SetSshEndpoints.ps1"


Write-Status "Creating Debugging..."
. $workingDir"Debugging\CreateDebugging.ps1"
CreateDebugging


# Creates the SQL cloud service, so has to come before CreateSql
Write-Status "Creating Quorum..."
. $workingDir"Quorum\CreateQuorum.ps1"
CreateQuorum


Write-Status "Installing Quorum Failover Clustering..."
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $quorumServerName
Invoke-Command -Session $session -FilePath $workingDir"Quorum\InstallQuorumFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName
Remove-PSSession -Session $session


. $workingDir"Sql\CreateSql.ps1"
CreateSql


Write-Status "Done!"