function Settings()
{
    # The below settings change depending on the region

    $location = "China East"
	$locationAbbrev = "CN-E"
    $subscriptionName = "Enterprise Trial"
    $publishSettingsName = "Enterprise Trial-6-13-2014-credentials"
    $azureStorageUrlPath = "chinacloudapi.cn" # Non-China: windows.net
    $azureCloudServiceUrlPath = "chinacloudapp.cn"  # Non-China: cloudapp.net

    # The above settings change depending on the region

    
    # The below settings may change depending on the region

    $Basic_A1 = "Small"
    $Standard_A2 = "Medium"
    $Basic_A2 = "Medium"
    $Basic_A3 = "Large"

    # The above settings may change depending on the region


    $delimiter = "-"
	$clusterName = "B"
	$capitalizedClusterName = $clusterName.ToUpperInvariant()
	$clusterPrefix = "$clusterName$delimiter"

	$clusterLocation = "$clusterPrefix$locationAbbrev"

    $affinityGroupName = $clusterLocation
    $affinityGroupDescription = "$capitalizedClusterName $location Affinity Group"
    $affinityGroupLabel = "$affinityGroupName Affinity Group"

    $virtualNetworkName = "$capitalizedClusterName $location NET"

    $storageAccountName = $clusterLocation.Replace($delimiter, "").ToLowerInvariant() # Storage account names must be between 3 and 24 characters in length and use numbers and lower-case letters only.
    $storageAccountLabel = "$capitalizedClusterName $location Storage Account"
    $storageAccountContainer = "https://$storageAccountName.blob.core.$azureStorageUrlPath/vhds/"

    $azureAvailabilitySetName = "$clusterLocation Availability Set"
    $dcCloudServiceName = "$clusterLocation" 
    $sqlCloudServiceName  = "$clusterLocation-SQL" 

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

    $dcServerName = "$locationAbbrev-10-Q1" # must be a valid DNS name (15 character limit)
    $queueServerName2 = "$locationAbbrev-11-Q2"
    $dcUsersPassword = "!Bubbajoe5312"

    $sqlDcUserName1 = "SQLSvc1"
    $sqlDcUserName2 = "SQLSvc2"
    $sqlUserName1 = "$domainName\$sqlDcUserName1"
    $sqlUserName2 = "$domainName\$sqlDcUserName2"
    $installUserName = "Install"
    $sqlServerAdminUserName = "sa"
    $sqlServerAdminPassword = "sdbl,DTP98101" # Needs to be the same password as used in SQL Image creation

    $webServerName1 = "$locationAbbrev-00-W1"
    $webServerName2 = "$locationAbbrev-01-W2"

    $mongoServerName1 = "$locationAbbrev-20-M1"
    $mongoServerName2 = "$locationAbbrev-21-M2"
    $mongoServerName3 = "$locationAbbrev-22-M3"

    $memcachedServerName1 = "$locationAbbrev-50-C1"
    $memcachedServerName2 = "$locationAbbrev-51-C2"

    $stagingServerName = "$locationAbbrev-60-S1"

    $quorumServerName = "$locationAbbrev-30-QM1" # 15 character limit

    $sqlServerName1 = "$locationAbbrev-40-SQL1"
    $sqlServerName2 = "$locationAbbrev-41-SQL2"

    $sqlAvailabilityGroupName = "$clusterLocation Availability Group"
    $sqlClusterName = "$locationAbbrev-SC" # must be a valid DNS name (15 character limit)?
    $sqlListenerName = "$locationAbbrev-L" # must be a valid DNS name (15 character limit)
    $endpointName = "ListenerEP" # 15 character limit
    $lbSetName = "$endpointName-LB" # from ConfigureAGListenerCloudOnly.ps1

    $sshExePath = "C:\Program Files (x86)\git\bin\ssh.exe"
    $scpExePath = "C:\Program Files (x86)\git\bin\scp.exe"
    $sshLocalCertificatePath = "C:\src\bran-the-builder\deploy_key.cer"
    $sshCertificateFingerprint = "‎730dcef947d1ec2c31e3ea4b3f291dfee3be00fd"
    $sshRemotePublicKeyPath = "/home/sysadmin/.ssh/authorized_keys"
    $sshLocalPublicKeyPath = "C:\src\bran-the-builder\deploy_key.rsa.pub"
    $sshLocalPrivateKeyPath = "C:\src\bran-the-builder\deploy_key.rsa"
}