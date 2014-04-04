function Storage()
{
    $storageAccount = $null

    try
    {
        $storageAccount = Get-AzureStorageAccount -StorageAccountName $storageAccountName
    }
    catch {}


    if ($storageAccount -eq $null)
    {
        New-AzureStorageAccount `
            -StorageAccountName $storageAccountName `
            -Label $storageAccountLabel `
            -AffinityGroup $affinityGroupName
    }

    Set-AzureSubscription `
        -SubscriptionName (Get-AzureSubscription -Current).SubscriptionName `
        -CurrentStorageAccountName $storageAccountName
}