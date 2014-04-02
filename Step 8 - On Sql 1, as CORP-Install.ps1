Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common $workingDir


. $workingDir"Sql\AddDbToAvailabilityGroup.ps1"
#AddDbToAvailabilityGroup "BuddyObjects-Test-BRADLEYSERB1"

AddDbToAvailabilityGroup "BuddyObjects-Queue-Test-BRADLEYSERB1"