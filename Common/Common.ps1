#TODO: add region code to machine .configs

function Common()
{
    . $workingDir"Common\WriteStatus.ps1"

    . $workingDir"Common\RegionSettings.ps1"
    . RegionSettings # Called with dot source, so the settings variables are global

    . $workingDir"Common\Settings.ps1"
    . Settings # Called with dot source, so the settings variables are global

    . $workingDir"Common\Auth.ps1"
    Auth

    . $workingDir"Common\Storage.ps1" #depends on Auth
    Storage

    # Image names are Azure Region-specific, so they have to be determined after Auth
    $winImage = (Get-AzureVMImage | where {$_.ImageName -like $winVmImageName} | sort PublishedDate -Descending)[0];
    $global:winImageName = $winImage.ImageName
    $global:linuxImageName = (Get-AzureVMImage | where {$_.Label -like $linuxVmImageName -and $_.ImageName -like "*-en-us-*"} | sort PublishedDate -Descending)[0].ImageName
}