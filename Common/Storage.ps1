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
            -Location $location `
            -Label $storageAccountLabel
    }

    Set-AzureSubscription `
        -SubscriptionName (Get-AzureSubscription -Default).SubscriptionName `
        -CurrentStorageAccountName $storageAccountName
}