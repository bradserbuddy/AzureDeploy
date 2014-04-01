function ConfigureDc($workingDir)
{
    . $workingDir"Dc\AddDcUsers.ps1"
    AddDcUsers

    . $workingDir"Dc\ConfigureDcPermissions.ps1"
    ConfigureDcPermissions
}