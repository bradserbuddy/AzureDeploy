Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common $workingDir


. $workingDir"Dc\CreateNetAndDc.ps1"
CreateNetAndDc $workingDir


. $workingDir"Web\CreateWeb.ps1"
CreateWeb $workingDir


. $workingDir"Web\SetWebEndpoints.ps1"
SetWebEndpoints $workingDir


. $workingDir"Mongo\CreateMongo.ps1"
CreateMongo $workingDir