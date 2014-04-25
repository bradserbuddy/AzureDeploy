#TODO: add region code to machine .configs

function Common()
{
    . $workingDir"Common\WriteStatus.ps1"

    . $workingDir"Common\Settings.ps1"
    . Settings # Called with dot source, so the settings variables are global

    . $workingDir"Common\Auth.ps1"
    Auth

    . $workingDir"Common\AffinityGroup.ps1"
    AffinityGroup

    . $workingDir"Common\Storage.ps1" #depends on Auth
    Storage
}