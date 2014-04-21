function AddDcUsers()
{
    $scriptBlock =
    {
        Import-Module ActiveDirectory

        $pwd = ConvertTo-SecureString $Using:dcUsersPassword -AsPlainText -Force

        $adUser = Get-ADUser -Filter {Name -eq $Using:installUserName} 

        if ($adUser -eq $null)
        {
            New-ADUser `
                -Name $Using:installUserName `
                -AccountPassword  $pwd `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Enabled $true
        }

        $adUser = Get-ADUser -Filter {Name -eq $Using:sqlDcUserName1} 

        if ($adUser -eq $null)
        {
            New-ADUser `
                -Name $Using:sqlDcUserName1 `
                -AccountPassword  $pwd `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Enabled $true
        }

        $adUser = Get-ADUser -Filter {Name -eq $Using:sqlDcUserName2} 

        if ($adUser -eq $null)
        {
            New-ADUser `
                -Name $Using:sqlDcUserName2 `
                -AccountPassword  $pwd `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Enabled $true
        }
    }

    RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $dcServerName $scriptBlock
}