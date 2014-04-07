Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common $workingDir


. $workingDir"Sql\CreateAvailabilityGroup.ps1"
CreateAvailabilityGroup "BuddyObjects"

. $workingDir"Sql\AddDbToAvailabilityGroup.ps1"
AddDbToAvailabilityGroup "buddy_queue"