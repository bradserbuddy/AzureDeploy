﻿function Settings()
{
    $location = "West US"
	$locationAbbrev = "wus"


    $subscriptionName = "Windows Azure for BizSpark Plus"


    $delimiter = "-"
	$clusterName = "b$($delimiter)v2"
	$capitalizedClusterName = $clusterName.ToUpperInvariant()
	$clusterPrefix = "$clusterName$delimiter"


	$clusterLocation = "$clusterPrefix$locationAbbrev"

    $affinityGroupName = $clusterLocation
    $affinityGroupDescription = "$capitalizedClusterName $location Affinity Group"
    $affinityGroupLabel = "$affinityGroupName Affinity Group"

    $virtualNetworkName = "$capitalizedClusterName $location NET"

    $storageAccountName = $clusterLocation.Replace($delimiter, "") # Storage account names must be between 3 and 24 characters in length and use numbers and lower-case letters only.
    $storageAccountLabel = "$capitalizedClusterName $location Storage Account"
    $storageAccountContainer = "https://" + $storageAccountName + ".blob.core.windows.net/vhds/"

    $azureAvailabilitySetName = "$clusterLocation Availability Set"
    $dcCloudServiceName = "$clusterLocation" 
    $sqlCloudServiceName  = "$clusterLocation-sql" 

    $vmAdminUser = "sysadmin" 
    $vmAdminPassword = "!Bubbajoe5312"

    $domainName= "corp"
	$buddyplatformDomainName = "buddyplatform"
    $FQDN = "$domainName.$($buddyplatformDomainName).com"
    $domainName = $domainName.ToUpperInvariant()
 	$domainNameAsPrefix = "$domainName\"
    $frontSubnetName = "Front"
    $backSubnetName = "Back"
    $dnsSettings = New-AzureDns -Name "BuddyBackDNS" -IPAddress "10.10.0.4"

    $dcServerName = "$locationAbbrev-10-q1" # must be a valid DNS name (15 character limit)
    $dcUsersPassword = "!Bubbajoe5312"
    $sqlDcUserName1 = "SQLSvc1"
    $sqlDcUserName2 = "SQLSvc2"
    $sqlUserName1 = "$domainName\$sqlDcUserName1"
    $sqlUserName2 = "$domainName\$sqlDcUserName2"
    $installUserName = "Install"

    $webServerName1 = "$locationAbbrev-00-web1"
    $webServerName2 = "$locationAbbrev-01-web2"

    $mongoServerName1 = "$locationAbbrev-20-m1"
    $mongoServerName2 = "$locationAbbrev-21-m2"

    $quorumServerName = "$locationAbbrev-30-qm1" # 15 character limit

    $sql1ServerName = "$locationAbbrev-40-sql1"
    $sql2ServerName = "$locationAbbrev-40-sql2"
    $sqlPassword = "sdbl,DTP" # Needs to be the same password as used in SQl Image creation

    $sqlAvailabilityGroupName = "$clusterLocation Availability Group"
    $sqlClusterName = "$locationAbbrev-SC" # must be a valid DNS name (15 character limit)?
    $sqlListenerName = "$locationAbbrev-L" # must be a valid DNS name (15 character limit)
    $endpointName = "ListenerEP" # 15 character limit
    $lbSetName = "$endpointName-LB" # from ConfigureAGListenerCloudOnly.ps1

    $dataDiskSize = 100

    $sshExePath = "C:\Program Files (x86)\git\bin\ssh.exe"
    $scpExePath = "C:\Program Files (x86)\git\bin\scp.exe"
    $sshLocalCertificatePath = "C:\src\bran-the-builder\deploy_key.cer"
    $sshCertificateFingerprint = "‎730dcef947d1ec2c31e3ea4b3f291dfee3be00fd"
    $sshRemotePublicKeyPath = "/home/sysadmin/.ssh/authorized_keys"
    $sshLocalPublicKeyPath = "C:\src\bran-the-builder\deploy_key.rsa.pub"
    $sshLocalPrivateKeyPath = "C:\src\bran-the-builder\deploy_key.rsa"
}