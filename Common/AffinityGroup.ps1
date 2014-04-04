function AffinityGroup()
{
    $affinityGroup = $null
    
    try
    {
        $affinityGroup = Get-AzureAffinityGroup -Name $affinityGroupName
    }
    catch {}

    if ($affinityGroup -eq $null)
    {
        New-AzureAffinityGroup `
            -Name $affinityGroupName `
            -Location $location `
            -Description $affinityGroupDescription `
            -Label $affinityGroupLabel
    }
}