Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

$vmAdminUser = "sysadmin"
$vmAdminPassword = "!Bubbajoe5312"
$testServerName = "b-v2-eus-test"
$testCloudServiceName = "b-v2-eus-test"
 
. $workingDir"External\InstallWinRMCertAzureVM.ps1" -SubscriptionName $subscriptionName -ServiceName $testCloudServiceName -Name $testServerName

$uri = Get-AzureWinRMUri -ServiceName $testCloudServiceName -Name $testServerName 

$credential = New-Object System.Management.Automation.PSCredential($vmAdminUser, $(ConvertTo-SecureString $vmAdminPassword -AsPlainText -Force))
	
$session = New-PSSession -ConnectionUri $uri -Credential $credential 

$directory = "c:\testDir"

Invoke-Command -Session $session –ScriptBlock { mkdir $Using:directory }

Remove-PSSession -Session $session

#{ dcpromo.exe /unattend /ReplicaOrNewDomain:Domain /NewDomain:Forest /NewDomainDNSName:$FQDN /ForestLevel:4 /DomainNetbiosName:$domainName /DomainLevel:4 /InstallDNS:Yes /ConfirmGc:Yes /CreateDNSDelegation:No /DatabasePath:"C:\Windows\NTDS" /LogPath:"C:\Windows\NTDS" /SYSVOLPath:"C:\Windows\SYSVOL" /SafeModeAdminPassword:$vmAdminPassword }
