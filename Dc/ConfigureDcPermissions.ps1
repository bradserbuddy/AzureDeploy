function ConfigureDcPermissions()
{
    $scriptBlock =
    {
        Cd ad:
        $sid = new-object System.Security.Principal.SecurityIdentifier (Get-ADUser $Using:installUserName).SID
        $guid = new-object Guid bf967a86-0de6-11d0-a285-00aa003049e2
        $ace1 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $sid,"CreateChild","Allow",$guid,"All"
        $dcDomainName = "DC=$Using:domainName,DC=$Using:buddyplatformDomainName,DC=com"
	    $corp = Get-ADObject -Identity $dcDomainName
        $acl = Get-Acl $corp
        $acl.AddAccessRule($ace1)
        Set-Acl -Path $dcDomainName -AclObject $acl
    }

    RunRemotely $vmAdminUser $vmAdminPassword $dcCloudServiceName $dcServerName $scriptBlock
}