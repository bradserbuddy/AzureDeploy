﻿Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common $workingDir


#Clear-Item WSMan:\localhost\Client\TrustedHosts
#Set-Item wsman:\localhost\Client\TrustedHosts -Value "$sql1ServerName.$FQDN,$sql2ServerName.$FQDN,$quorumServerName.$FQDN" -Force


#[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$false}


$configureAGListenerCloudOnlyScript = $workingDir + "ConfigureAGListenerCloudOnly.ps1"
& $configureAGListenerCloudOnlyScript  -AGName $sqlAvailabilityGroupName -ListenerName $sqlListenerName -ServiceName $sqlServiceName -WSFCNodes $sql1ServerName,$sql2ServerName,$quorumServerName -DomainAccount "$domainNameAsPrefix$installUserName" -Password $dcUsersPassword -InstallWinRMCert