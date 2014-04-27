Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common


Write-Status "Installing Sql Failover Clustering..."
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sql1ServerName
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlPassword
Remove-PSSession -Session $session
$session = GetSession $vmAdminUser $vmAdminPassword $sqlCloudServiceName $sql2ServerName
Invoke-Command -Session $session -FilePath $workingDir"Sql\InstallSqlFailoverClustering.ps1" -ArgumentList $domainNameAsPrefix, $installUserName, $vmAdminUser, $sqlPassword
Remove-PSSession -Session $session


Write-Status "Install Availability Group Prep..."
. $workingDir"Sql\InstallAvailabilityGroupPrep.ps1"
InstallAvailabilityGroupPrep $sql1ServerName $sqlUserName1 $vmAdminPassword
InstallAvailabilityGroupPrep $sql2ServerName $sqlUserName2 $vmAdminPassword


Add-WindowsFeature 'Failover-Clustering', 'RSAT-Clustering-PowerShell', 'RSAT-Clustering-CmdInterface'


Set-ExecutionPolicy Unrestricted -Force
& $workingDir"External\CreateAzureFailoverCluster.ps1" -ClusterName $sqlClusterName -ClusterNodes $sql1ServerName, $sql2ServerName, $quorumServerName -Force


Write-Status "Install Availability Group..."
. $workingDir"Sql\InstallAvailabilityGroup.ps1"
InstallAvailabilityGroup