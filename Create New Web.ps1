Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

. $workingDir"Common\RunRemotely.ps1"
. $workingDir"Common\CreateVm.ps1"
. $workingDir"Common\RdpManageCert.ps1"


Write-Status "Creating Web..."
. $workingDir"Web\CreateWeb.ps1"
CreateWeb


Write-Status "Done!"