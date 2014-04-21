 function RunRemotely($userName, $password, $cloudServiceName, $serverName, $scriptBlock)
 {
    $credential = New-Object System.Management.Automation.PSCredential($userName, $(ConvertTo-SecureString $password -AsPlainText -Force))

    $uri = Get-AzureWinRMUri -ServiceName $cloudServiceName -Name $serverName 

    $session = New-PSSession -ConnectionUri $uri -Credential $credential 

	Invoke-Command -Session $session –ScriptBlock $scriptBlock
    
    Remove-PSSession -Session $session
}