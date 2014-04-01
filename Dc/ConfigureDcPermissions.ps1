function ConfigureDcPermissions()
{
    Cd ad:
    $sid = new-object System.Security.Principal.SecurityIdentifier (Get-ADUser $installUserName).SID
    $guid = new-object Guid bf967a86-0de6-11d0-a285-00aa003049e2
    $ace1 = new-object System.DirectoryServices.ActiveDirectoryAccessRule $sid,"CreateChild","Allow",$guid,"All"
    $corp = Get-ADObject -Identity "DC=corp,DC=buddy,DC=com"
    $acl = Get-Acl $corp
    $acl.AddAccessRule($ace1)
    Set-Acl -Path "DC=corp,DC=buddy,DC=com" -AclObject $acl
}