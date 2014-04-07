﻿Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common $workingDir


#Clear-Item WSMan:\localhost\Client\TrustedHosts
#Set-Item wsman:\localhost\Client\TrustedHosts -Value "$sql1ServerName.$FQDN,$sql2ServerName.$FQDN,$quorumServerName.$FQDN" -Force
#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
#sqlcmd -S ListenerSeAsia,1433 -d BuddyObjects-Test-BRADLEYSERB1 -q "select @@servername, db_name()" -l 15 -U CORP\Install -P !Bubbajoe5312


$configureAGListenerCloudOnlyScript = $workingDir + "External\ConfigureAGListenerCloudOnly.ps1"
& $configureAGListenerCloudOnlyScript  -AGName $sqlAvailabilityGroupName -ListenerName $sqlListenerName -ServiceName $sqlCloudServiceName -WSFCNodes $sql1ServerName,$sql2ServerName,$quorumServerName -DomainAccount "$domainNameAsPrefix$installUserName" -Password $dcUsersPassword