function AffinityGroup()
{
    $affinityGroup = Get-AzureAffinityGroup -Name $affinityGroupName

    if ($affinityGroup -eq $null)
    {
        New-AzureAffinityGroup `
            -Name $affinityGroupName `
            -Location $location `
            -Description $affinityGroupDescription `
            -Label $affinityGroupLabel
    }
}