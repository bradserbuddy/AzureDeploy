function Auth($workingDir)
{
    $allSubscriptions = Get-AzureSubscription

    if ($allSubscriptions -eq $null)
    {
        # call Get-AzurePublishSettingsFile to get an updated .publishsettings if needed
        $publishSettings = $workingDir + "Windows Azure MSDN - Visual Studio Ultimate-Windows Azure for BizSpark Plus-4-11-2014-credentials.publishsettings"

        Import-AzurePublishSettingsFile -PublishSettingsFile $publishSettings
    }

    Select-AzureSubscription -Default -SubscriptionName "Windows Azure for BizSpark Plus"

    $currentAccount = Get-AzureAccount
    
    if ($currentAccount -eq $null)
    {
        Add-AzureAccount
    }

    $subscriptionId = (Get-AzureSubscription -Default).SubscriptionId
}