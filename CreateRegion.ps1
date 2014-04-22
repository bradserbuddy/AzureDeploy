Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

. $workingDir"Common\RunRemotely.ps1"

#. $workingDir"Add-VirtualNetworkSite.ps1"
#Add-VirtualNetworkSite $virtualNetworkName $affinityGroupName "10.10.0.0/16" "10.10.1.0/24" "10.10.2.0/24"

<#. $workingDir"Dc\CreateDc.ps1"
CreateDc

. $workingDir"Dc\ConfigureDc.ps1"
ConfigureDc

. $workingDir"Web\CreateWeb.ps1"
CreateWeb

. $workingDir"Web\SetWebEndpoints.ps1"
SetWebEndpoints#>

. $workingDir"Mongo\CreateMongo.ps1"
CreateMongo

<#. $workingDir"Quorum\CreateQuorum.ps1"
CreateQuorum

. $workingDir"Quorum\InstallQuorumFailoverClustering.ps1"
RunRemotely OnQuorum -> InstallQuorumFailoverClustering

. $workingDir"Sql\CreateSql.ps1"
CreateSql

#TODO: create master\web1 share for slave\web2


. $workingDir"Sql\InstallSqlFailoverClustering.ps1"
RunRemotely OnEachSql -> InstallSqlFailoverClustering

. $workingDir"ConfigureAvailabilityGroup.ps1"
RunRemotely OnSql1 as CORP\Install -> ConfigureAvailabilityGroup $workingDir

. $workingDir"Sql\CreateAvailabilityGroup.ps1"
RunRemotely OnSql1 as CORP\Install -> CreateAvailabilityGroup "BuddyObjects"

. $workingDir"Sql\AddDbToAvailabilityGroup.ps1"
RunRemotely OnSql1 as CORP\Install -> AddDbToAvailabilityGroup "buddy_queue"

# Not in ISE
$configureAGListenerCloudOnlyScript = $workingDir + "External\ConfigureAGListenerCloudOnly.ps1"
& $configureAGListenerCloudOnlyScript  -AGName $sqlAvailabilityGroupName -ListenerName $sqlListenerName -ServiceName $sqlCloudServiceName -WSFCNodes $sql1ServerName,$sql2ServerName,$quorumServerName -DomainAccount "$domainNameAsPrefix$installUserName" -Password $dcUsersPassword
#>