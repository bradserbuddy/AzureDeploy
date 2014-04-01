function AddDcUsers()
{
    Import-Module ActiveDirectory

    $pwd = ConvertTo-SecureString $dcUsersPassword -AsPlainText -Force

    $adUser = Get-ADUser -Filter {Name -eq $installUserName} 

    if ($adUser -eq $null)
    {
        New-ADUser `
            -Name $installUserName `
            -AccountPassword  $pwd `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false `
            -Enabled $true
    }

    $adUser = Get-ADUser -Filter {Name -eq $sqlDcUserName1} 

    if ($adUser -eq $null)
    {
        New-ADUser `
            -Name $sqlDcUserName1 `
            -AccountPassword  $pwd `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false `
            -Enabled $true
    }

    $adUser = Get-ADUser -Filter {Name -eq $sqlDcUserName2} 

    if ($adUser -eq $null)
    {
        New-ADUser `
            -Name $sqlDcUserName2 `
            -AccountPassword  $pwd `
            -PasswordNeverExpires $true `
            -ChangePasswordAtLogon $false `
            -Enabled $true
    }
}