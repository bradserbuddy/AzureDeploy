function CreateNetAndDc($workingDir)
{

    . $workingDir"NetConfig.ps1"
    NetConfig

    . $workingDir"Dc\CreateDc.ps1"
    CreateDc $workingDir
}