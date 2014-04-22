function AddDcUsers()
{
    $scriptBlock =
    {
        Import-Module ActiveDirectory

        $pwd = ConvertTo-SecureString $Using:dcUsersPassword -AsPlainText -Force

        $installUserName = $Using:installUserName # fix scope for Filter
        $adUser = Get-ADUser -Filter {Name -eq $installUserName} 

        if ($adUser -eq $null)
        {
            New-ADUser `
                -Name $Using:installUserName `
                -AccountPassword  $pwd `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Enabled $true
        }

        $sqlDcUserName1 = $Using:sqlDcUserName1
        $adUser = Get-ADUser -Filter {Name -eq $sqlDcUserName1} 

        if ($adUser -eq $null)
        {
            New-ADUser `
                -Name $Using:sqlDcUserName1 `
                -AccountPassword  $pwd `
                -PasswordNeverExpires $true `
                -ChangePasswordAtLogon $false `
                -Enabled $true
        }

        $sqlDcUserName2 = $Using:sqlDcUserName2
        $adUser = Get-ADUser -Filter {Name -eq $sqlDcUserName2} 

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