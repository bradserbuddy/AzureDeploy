Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common


Write-Status "Install Availability Group Prep..."
. $workingDir"Sql\InstallAvailabilityGroupPrep.ps1"
InstallAvailabilityGroupPrep $sqlServerName1 $sqlUserName1 $vmAdminPassword
InstallAvailabilityGroupPrep $sqlServerName2 $sqlUserName2 $vmAdminPassword


Add-WindowsFeature 'Failover-Clustering', 'RSAT-Clustering-PowerShell', 'RSAT-Clustering-CmdInterface'


Set-ExecutionPolicy Unrestricted -Force
& $workingDir"External\CreateAzureFailoverCluster.ps1" -ClusterName $sqlClusterName -ClusterNodes $sqlServerName1, $sqlServerName2, $quorumServerName -Force


Write-Status "Install Availability Group..."
. $workingDir"Sql\InstallAvailabilityGroup.ps1"
InstallAvailabilityGroup


Write-Status "Done!  Be sure to log out before continuing with Step 4."