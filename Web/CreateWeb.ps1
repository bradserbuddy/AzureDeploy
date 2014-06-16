function CreateWeb()
{
    CreateWebVm $webServerName1

    CreateWebVm $webServerName2

    # mkdir c:\buddyapps 
    # NET SHARE buddyapps=c:\buddyapps /GRANT:Everyone,FULL
}

function CreateWebVm($serverName)
{
    $installAspNetScriptBlock =
    {
        Install-WindowsFeature -Name Web-Asp-Net45, Web-Asp-Net, AS-NET-Framework, AS-Web-Support
    }
    
    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName

    if ($vm -eq $null)
    {
        $vm = GetWinVmConfig $dcCloudServiceName $serverName $Standard_A2

        $vm | Set-AzureSubnet `
                -SubnetNames $frontSubnetName |
				New-AzureVM `
					-ServiceName $dcCloudServiceName `
                    -WaitForBoot

        RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $serverName $installAspNetScriptBlock

        RdpManageCert $dcCloudServiceName $serverName
    }
}