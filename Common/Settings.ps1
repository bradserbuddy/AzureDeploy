function Settings()
{
    $subscriptionName = "Windows Azure BizSpark 1111"

    $delimiter = "-"
	$clusterName = "b$($delimiter)v2"
	$capitalizedClusterName = $clusterName.ToUpperInvariant()
	$clusterPrefix = "$clusterName$delimiter"
    $location = "East US"
	$locationAbbrev = "eus"


	$clusterLocation = "$clusterPrefix$locationAbbrev"

    $affinityGroupName = $clusterLocation
    $affinityGroupDescription = "$capitalizedClusterName $location Affinity Group"
    $affinityGroupLabel = "$affinityGroupName Affinity Group"

    $virtualNetworkName = "$capitalizedClusterName $location NET"

    $storageAccountName = $clusterLocation.Replace($delimiter, "") # Storage account names must be between 3 and 24 characters in length and use numbers and lower-case letters only.
    $storageAccountLabel = "$capitalizedClusterName $location Storage Account"
    $storageAccountContainer = "https://" + $storageAccountName + ".blob.core.windows.net/vhds/"

    $azureAvailabilitySetName = "$clusterLocation Availability Set"
    $dcCloudServiceName = "$clusterLocation-dc" 
    $sqlCloudServiceName  = "$clusterLocation-sql" 

    $vmAdminUser = "sysadmin" 
    $vmAdminPassword = "!Bubbajoe5312"

    $domainName= "corp"
	$buddyplatformDomainName = "buddy" # Update Step 2
    $FQDN = "$domainName.$($buddyplatformDomainName).com"
    $domainName = $domainName.ToUpperInvariant()
 	$domainNameAsPrefix = "$domainName\"
    $subnetName = "Back"
    $dnsSettings = New-AzureDns -Name "BuddyBackDNS" -IPAddress "10.10.0.4"

    $dcServerName = "$clusterLocation-dc" # 15 character limit
    $dcUsersPassword = "!Bubbajoe5312"
    $sqlDcUserName1 = "SQLSvc1"
    $sqlDcUserName2 = "SQLSvc2"
    $sqlUserName1 = "$domainName\$sqlDcUserName1"
    $sqlUserName2 = "$domainName\$sqlDcUserName2"
    $installUserName = "Install"

    $webServerName1 = "$clusterLocation-web1"
    $webServerName2 = "$clusterLocation-web2"

    $mongoServerName1 = "$clusterLocation-m1"
    $mongoServerName2 = "$clusterLocation-m2"

    $quorumServerName = "$clusterLocation-qm" # 15 character limit

    $sql1ServerName = "$clusterLocation-sql1"
    $sql2ServerName = "$clusterLocation-sql2"
    $sqlPassword = "sdbl,DTP"

    $sqlAvailabilityGroupName = "$clusterLocation Availability Group"
    $sqlClusterName = "$($clusterLocation)SqlCluster" # must be a valid DNS name
    $sqlListenerName = "$($clusterLocation)Listener"

    $dataDiskSize = 100
}