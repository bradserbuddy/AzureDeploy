function NetConfig()
{
    $networkConfig = Get-AzureVNetConfig

    if ($networkConfig -eq $null)
    {
        Set-AzureVNetConfig `
            -ConfigurationPath $networkConfigPath
    }
}