Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\ServiceManagement\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common\Common.ps1"
. Common


Write-Status "Install Databases in Availability Group..."
. $workingDir"Sql\CreateSqlAvailabilityGroup.ps1"
CreateSqlAvailabilityGroup "BuddyObjects"


. $workingDir"Sql\AddDbToSqlAvailabilityGroup.ps1"
AddDbToSqlAvailabilityGroup "buddy_queue"