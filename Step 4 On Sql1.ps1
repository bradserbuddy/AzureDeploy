Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common

. $workingDir"Common\RunRemotely.ps1"


echo "Install Databases in Availability Group..."
. $workingDir"Sql\CreateSqlAvailabilityGroup.ps1"
CreateSqlAvailabilityGroup "BuddyObjects"


. $workingDir"Sql\AddDbToSqlAvailabilityGroup.ps1"
AddDbToSqlAvailabilityGroup "buddy_queue"