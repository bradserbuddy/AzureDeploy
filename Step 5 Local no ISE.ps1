Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

. $workingDir"Common\RunRemotely.ps1"


# Not in ISE!
& $workingDir"External\ConfigureAGListenerCloudOnly.ps1" -AGName $sqlAvailabilityGroupName -EndpointName $endpointName -ListenerName $sqlListenerName -ServiceName $sqlCloudServiceName -WSFCNodes $sql1ServerName,$sql2ServerName,$quorumServerName -DomainAccount "$domainNameAsPrefix$installUserName" -Password $dcUsersPassword


# set endpoint security
$sqlCloudServiceNameIpAddress = [System.Net.Dns]::GetHostAddresses((Get-AzureDeployment -ServiceName $sqlCloudServiceName).Url.DnsSafeHost) | foreach { $_.IPAddressToString }
$sqlCloudServiceNameIpAddressSubnet = "$sqlCloudServiceNameIpAddress/32"

$acl = New-AzureAclConfig

Set-AzureAclConfig –AddRule –ACL $acl –Order 100 –Action Permit ` 
    –RemoteSubnet $sqlCloudServiceNameIpAddressSubnet `
    –Description "Remote App ACL config"

Set-AzureLoadBalancedEndpoint –ServiceName $sqlCloudServiceName –LBSetName $lbSetName ` 
    -Protocol tcp –LocalPort 1433 –PublicPort 1433 –ProbePort 59999 `
    -ProbeProtocolTCP -DirectServerReturn $true –ACL $acl