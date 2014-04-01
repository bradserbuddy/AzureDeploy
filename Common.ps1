function Common($workingDir)
{
    . $workingDir"Common\Settings.ps1"
    . Settings $workingDir # Called with dot source, so the settings variables are global

    . $workingDir"Common\Auth.ps1"
    Auth $workingDir

    . $workingDir"Common\AffinityGroup.ps1"
    AffinityGroup

    . $workingDir"Common\Storage.ps1" #depends on Auth
    Storage
}