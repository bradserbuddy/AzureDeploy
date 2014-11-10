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

    . $workingDir"Common\AffinityGroup.ps1"
    AffinityGroup

    . $workingDir"Common\Storage.ps1" #depends on Auth
    Storage

    # Image names are Azure Region-specific, so they have to be determined after Auth
    $global:winImageName = (Get-AzureVMImage | where {$_.Label -like "Windows Server 2012 R2 Datacenter*" -and $_.ImageName -like "*-en.us-*"} | sort PublishedDate -Descending)[0].ImageName
    $global:linuxImageName = (Get-AzureVMImage | where {$_.Label -like "Ubuntu Server 12.04.4 LTS" -and $_.ImageName -like "*-en-us-*"} | sort PublishedDate -Descending)[0].ImageName
}