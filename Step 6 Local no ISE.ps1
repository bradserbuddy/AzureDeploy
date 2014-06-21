Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common


# Not in ISE!
& $workingDir"External\ConfigureAGListenerCloudOnly.ps1" -AGName $sqlAvailabilityGroupName -EndpointName $endpointName -ListenerName $sqlListenerName -ServiceName $sqlCloudServiceName -WSFCNodes $sqlServerName1,$sqlServerName2,$quorumServerName -DomainAccount "$domainNameAsPrefix$installUserName" -Password $dcUsersPassword


Write-Status "Set Endpoint Security..."

$dnsSafeHost = (Get-AzureDeployment -ServiceName $dcCloudServiceName).Url.DnsSafeHost
$dcCloudServiceIpAddress = [System.Net.Dns]::GetHostAddresses($dnsSafeHost) | foreach { $_.IPAddressToString }
$dcCloudServiceIpAddressSubnet = "$dcCloudServiceIpAddress/32"

$acl = New-AzureAclConfig

Set-AzureAclConfig –AddRule –ACL $acl –Order 100 –Action Permit –RemoteSubnet $dcCloudServiceIpAddressSubnet –Description "$dcCloudServiceName.$azureCloudServiceUrlPath subnet"

Set-AzureLoadBalancedEndpoint –ServiceName $sqlCloudServiceName –LBSetName $lbSetName -Protocol tcp -ProbeProtocolTCP -ACL $acl

Write-Status "Done!"