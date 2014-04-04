function CreateNetAndDc($workingDir)
{
    . $workingDir"Add-VirtualNetworkSite.ps1"
    Add-VirtualNetworkSite $virtualNetworkName $affinityGroupName "10.10.0.0/16" "10.10.1.0/24" "10.10.2.0/24"

    . $workingDir"Dc\CreateDc.ps1"
    CreateDc $workingDir
}