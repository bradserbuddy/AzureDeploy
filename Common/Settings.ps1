function Settings()
{
    $subscriptionName = "Windows Azure BizSpark 1111"

	$clusterName = "v2"
	$capitalizedClusterName = $clusterName.ToUpperInvariant()
	$clusterPrefix = "$clusterName-"
    $location = "Eastern US"
	$locationAbbrev = "eus"


	$clusterLocation = "$clusterPrefix$locationAbbrev"

    $affinityGroupName = $clusterLocation
    $affinityGroupDescription = "$capitalizedClusterName $location Affinity Group"
    $affinityGroupLabel = "$affinityGroupName Affinity Group"

    $virtualNetworkName = "$capitalizedClusterName $location NET"

    $storageAccountName = $clusterLocation
    $storageAccountLabel = "$capitalizedClusterName $location Storage Account"
    $storageAccountContainer = "https://" + $storageAccountName + ".blob.core.windows.net/vhds/"

    $azureAvailabilitySetName = "$clusterLocation Availability Set"
    $dcCloudServiceName = "Buddy-$clusterLocation-dc" 
    $sqlCloudServiceName  = "$Buddy-clusterLocation-sql" 

    $vmAdminUser = "sysadmin" 
    $vmAdminPassword = "!Bubbajoe5312"

    $domainName= "corp"
    $FQDN = "$domainName.buddyplatform.com"
    $domainName = $domainName.ToUpperInvariant()
    $subnetName = "Back"
    $dnsSettings = New-AzureDns -Name "BuddyBackDNS" -IPAddress "10.10.0.4"

    $dcServerName = "$clusterLocation-dc" # 15 character limit
    $dcUsersPassword = "!Bubbajoe5312"
    $sqlDcUserName1 = "SQLSvc1"
    $sqlDcUserName2 = "SQLSvc2"
    $sqlUserName1 = "$domainName\$sqlDcUserName1"
    $sqlUserName2 = "$domainName\$sqlDcUserName2"
    $installUserName = "Install"

    $quorumServerName = "$clusterLocation-qm" # 15 character limit

    $sql1ServerName = "$clusterLocation-sql1"
    $sql2ServerName = "$clusterLocation-sql2"
    $sqlPassword = "sdbl,DTP"

    $sqlAvailabilityGroupName = "$clusterLocation Availability Group"
    $sqlClusterName = "$clusterLocation Sql Cluster"
    $sqlListenerName = "$clusterLocation Listener"

    $dataDiskSize = 100
}