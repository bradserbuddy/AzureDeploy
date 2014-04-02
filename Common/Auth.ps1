function Auth($workingDir)
{
    $allSubscriptions = Get-AzureSubscription

    if ($allSubscriptions -eq $null)
    {
        # call Get-AzurePublishSettingsFile to get an updated .publishsettings if needed
        $publishSettings = $workingDir + "Windows Azure MSDN - Visual Studio Ultimate-Windows Azure BizSpark 1111-3-25-2014-credentials.publishsettings"

        Import-AzurePublishSettingsFile -PublishSettingsFile $publishSettings
    }

    Select-AzureSubscription -Default -SubscriptionName "Windows Azure BizSpark 1111"

    $currentAccount = Get-AzureAccount
    
    if ($currentAccount -eq $null)
    {
        Add-AzureAccount
    }

    $subscriptionId = (Get-AzureSubscription -Default).SubscriptionId
}