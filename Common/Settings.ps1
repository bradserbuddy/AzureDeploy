function Settings()
{
    $subscriptionName = "Windows Azure BizSpark 1111"

    $location = "Southeast Asia"

    $affinityGroupName = "buddy-v2-seasia"
    $affinityGroupDescription = "buddy-v2-seasia HADR Affinity Group"
    $affinityGroupLabel = "buddy-v2-seasia Affinity Group"

    $networkConfigPath = $workingDir + "NetworkConfiguration.netcfg"

    $virtualNetworkName = "Buddy Southeast Asia NET"

    $storageAccountName = "buddyseasia"
    $storageAccountLabel = "Buddy Southeast Asia Storage Account"
    $storageAccountContainer = "https://" + $storageAccountName + ".blob.core.windows.net/vhds/"

    $availabilitySetName = "SQLHADR"
    $dcServiceName = "buddy-v2-seasia-dc" 
    $sqlServiceName  = "buddy-v2-seasia-sql" 

    $vmAdminUser = "sysadmin" 
    $vmAdminPassword = "!Bubbajoe5312"

    $domainName= "corp"
    $domainNameAsPrefix= "CORP\"
    $FQDN = "corp.buddy.com" # corp.buddyplatform.com
    $subnetName = "Back"
    $dnsSettings = New-AzureDns -Name "BuddyBackDNS" -IPAddress "10.10.0.4"

    $dcServerName = "v2-seasia-dc" # 15 character limit
    $dcUsersPassword = "!Bubbajoe5312"
    $sqlDcUserName1 = "SQLSvc1"
    $sqlDcUserName2 = "SQLSvc2"
    $sqlUserName1 = "$domainNameAsPrefix$sqlDcUserName1"
    $sqlUserName2 = "$domainNameAsPrefix$sqlDcUserName2"
    $installUserName = "Install"

    $quorumServerName = "v2-seasia-qm" # 15 character limit

    $sql1ServerName = "v2-seasia-sql1"
    $sql2ServerName = "v2-seasia-sql2"
    $sqlPassword = "sdbl,DTP"

    $sqlAvailabilityGroupName = "AG1"
    $sqlClusterName = "ClusterSeAsia"
    $sqlListenerName = "ListenerSeAsia"

    $dataDiskSize = 100
}