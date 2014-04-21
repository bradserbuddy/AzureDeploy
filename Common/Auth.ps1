function Auth()
{
    # Ensure that we are not already logged in to Azure
    Get-AzureAccount | ForEach-Object { Remove-AzureAccount $_.Name -Force }

    $allSubscriptions = Get-AzureSubscription

    if ($allSubscriptions -eq $null)
    {
        # call Get-AzurePublishSettingsFile to get an updated .publishsettings if needed
        $publishSettings = $workingDir + "Windows Azure MSDN - Visual Studio Ultimate-Windows Azure for BizSpark Plus-4-11-2014-credentials.publishsettings"

        Import-AzurePublishSettingsFile -PublishSettingsFile $publishSettings
    }

    Select-AzureSubscription -Default -SubscriptionName $subscriptionName

    $subscriptionId = (Get-AzureSubscription -Default).SubscriptionId
}