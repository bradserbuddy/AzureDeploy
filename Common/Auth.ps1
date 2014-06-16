function Auth()
{
    # Ensure that we are not already logged in to Azure
    Get-AzureAccount | ForEach-Object { Remove-AzureAccount $_.Name -Force }

    $subscription = Get-AzureSubscription | where {$_.SubscriptionName -like $subscriptionName}

    if ($subscription -eq $null)
    {
        # Get-AzureEnvironment will give you the URL to get the .publishsettings file
        # or call Get-AzurePublishSettingsFile (US only) to get an updated .publishsettings if needed
        $publishSettings = "$workingDir$publishSettingsName.publishsettings"

        Import-AzurePublishSettingsFile -PublishSettingsFile $publishSettings
    }

    Select-AzureSubscription -Default -SubscriptionName $subscriptionName

    $subscriptionId = (Get-AzureSubscription -Default).SubscriptionId
}