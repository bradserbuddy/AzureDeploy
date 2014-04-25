Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common


Write-Host "Install Availability Group Prep..."
. $workingDir"Sql\InstallAvailabilityGroupPrep.ps1"
InstallAvailabilityGroupPrep $sql1ServerName $sqlUserName1 $vmAdminPassword
InstallAvailabilityGroupPrep $sql2ServerName $sqlUserName2 $vmAdminPassword


Add-WindowsFeature 'Failover-Clustering', 'RSAT-Clustering-PowerShell', 'RSAT-Clustering-CmdInterface'


Set-ExecutionPolicy Unrestricted -Force
& $workingDir"External\CreateAzureFailoverCluster.ps1" -ClusterName $sqlClusterName -ClusterNodes $sql1ServerName, $sql2ServerName, $quorumServerName -Force


Write-Host "Install Availability Group..."
. $workingDir"Sql\InstallAvailabilityGroup.ps1"
InstallAvailabilityGroup