Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

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



#TODO: set security on SQL AlwaysOn listener endpoint like so:

#$ApplicationCloudServiceIPsubnet = "<<<Public Cloud Service IP Address of your application>>>/32"

#$ServiceName = "<<<cloud service name containing SQL Server VMs>>>"

#$LBSetName = "<<<Load Balancer Set name used for AG Listener configuration"

#$acl = New-AzureAclConfig

#Set-AzureAclConfig –AddRule –ACL $acl –Order 100 –Action Permit ` 

#–RemoteSubnet $ApplicationCloudServiceIPsubnet
#–Description "Remote App ACL config"

#Set-AzureLoadBalancedEndpoint –ServiceName $sqlServiceName –LBSetName $LBSetName ` 

#-Protocol tcp –LocalPort 1433 –PublicPort 1433 –ProbePort 59999 `
#-ProbeProtocolTCP -DirectServerReturn $true –ACL $acl