function Storage()
{
    $storageAccount = Get-AzureStorageAccount -StorageAccountName $storageAccountName

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