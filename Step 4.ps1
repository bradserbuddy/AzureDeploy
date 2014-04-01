Import-Module "C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\Azure\Azure.psd1"

$ErrorActionPreference = "Stop"

$workingDir = (Split-Path -parent $MyInvocation.MyCommand.Definition) + "\"

. $workingDir"Common.ps1"
. Common $workingDir


. $workingDir"Quorum\CreateQuorum.ps1"
CreateQuorum $workingDir

. $workingDir"Sql\CreateSql.ps1"
CreateSql $workingDir