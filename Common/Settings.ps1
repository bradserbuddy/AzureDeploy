function Settings()
{
    $delimiter = "-"
	$clusterName = "B"
	$capitalizedClusterName = $clusterName.ToUpperInvariant()
	$clusterPrefix = "$clusterName$delimiter"

	$clusterLocation = "$clusterPrefix$locationAbbrev"


    $webAvailabilitySetName = "$clusterLocation-Web"
    $servicesAvailabilitySetName = "$clusterLocation-Services"
    $memcachedAvailabilitySetName = "$clusterLocation-Memcached"
    $debuggingAvailabilitySetName = "$clusterLocation-Debug"

    $virtualNetworkName = "Group $clusterLocation $clusterLocation-Net"

    # buddy is hard-coded here instead of the previous 'b' value because 'base' (a.k.a. buddy asia east) is a reserved name in Azure Storage
    $storageAccountName = "b$locationAbbrev".Replace($delimiter, "").ToLowerInvariant() # Storage account names must be between 3 and 24 characters in length and use numbers and lower-case letters only.
    $storageAccountLabel = "$capitalizedClusterName $location Storage Account"
    $storageAccountContainer = "https://$storageAccountName.blob.core.$azureStorageUrlPath/vhds/"

    $winVmImageName = "Buddy-WebFrontend-R6-os-2015-05-13"
    $linuxVmImageName = "Ubuntu Server 12.04.4 LTS"

    $cloudServiceName = "$clusterLocation-FE"

    $vmAdminUser = "sysadmin" 
    $vmAdminPassword = "!Bubbajoe5312"

    $domainName= "corp"
	$buddyplatformDomainName = "buddyplatform"
    $FQDN = "$domainName.$($buddyplatformDomainName).com"
    $domainName = $domainName.ToUpperInvariant()
 	$domainNameAsPrefix = "$domainName\"
    $frontEndSubnetName = "Frontend"
    $backEndSubnetName = "Backend"

    $addressTuple = "10.11."
    $frontEndSubnetTuple = $addressTuple + "0."
    $backEndSubnetTuple = $addressTuple + "1."

    $addressSpaceAddressPrefix = $addressTuple + "0.0/8"
    $frontEndSubnetAddressPrefix = $frontEndSubnetTuple + "0/24"
    $backEndSubnetAddressPrefix = $backEndSubnetTuple + "0/24"

    $servicesServerName0 = "$clusterLocation-50-Q0" # must be a valid DNS name (15 character limit)
    $servicesServerName1 = "$clusterLocation-51-Q1"

    $servicesServerIP0 = $backEndSubnetTuple + "50"
    $servicesServerIP1 = $backEndSubnetTuple + "51"

    $webServerName0 = "$clusterLocation-00-W0"
    $webServerName1 = "$clusterLocation-01-W1"
    $webServerName2 = "$clusterLocation-02-W2"
    $webServerName3 = "$clusterLocation-03-W3"
    $webServerName4 = "$clusterLocation-04-W4"
    $webServerName5 = "$clusterLocation-05-W5"
    $webServerName6 = "$clusterLocation-06-W6"
    $webServerName7 = "$clusterLocation-07-W7"
    $webServerName8 = "$clusterLocation-08-W8"

    $webServerIP0 = $frontEndSubnetTuple + "100" # .0 through .3 are reserved
    $webServerIP1 = $frontEndSubnetTuple + "101"
    $webServerIP2 = $frontEndSubnetTuple + "102"
    $webServerIP3 = $frontEndSubnetTuple + "103"
    $webServerIP4 = $frontEndSubnetTuple + "104"
    $webServerIP5 = $frontEndSubnetTuple + "105"
    $webServerIP6 = $frontEndSubnetTuple + "106"
    $webServerIP7 = $frontEndSubnetTuple + "107"
    $webServerIP8 = $frontEndSubnetTuple + "108"

    $memcachedServerName0 = "$clusterLocation-70-C0"
    $memcachedServerName1 = "$clusterLocation-71-C1"

    $memcachedServerIP0 = $frontEndSubnetTuple + "70"
    $memcachedServerIP1 = $frontEndSubnetTuple + "71"

    $debuggingServerName = "$clusterLocation-90-D0"
    $debuggingServerIP = $frontEndSubnetTuple + "90"
}