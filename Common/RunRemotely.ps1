 function RunRemotely($userName, $password, $cloudServiceName, $serverName, $scriptBlock)
 {
    $session = GetSession $userName $password $cloudServiceName $serverName

....Invoke-Command -Session $session –ScriptBlock $scriptBlock

    Remove-PSSession -Session $session
}

function GetSession($userName, $password, $cloudServiceName, $serverName)
{
    $credential = New-Object System.Management.Automation.PSCredential($userName, $(ConvertTo-SecureString $password -AsPlainText -Force))

    $uri = Get-AzureWinRMUri -ServiceName $cloudServiceName -Name $serverName 

    $session = New-PSSession -ConnectionUri $uri -Credential $credential

    return $session
}