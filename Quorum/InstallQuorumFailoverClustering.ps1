param($domainNameAsPrefix, $installUserName)

function InstallQuorumFailoverClustering()
{
    Import-Module ServerManager
    Add-WindowsFeature Failover-Clustering

    net localgroup administrators $domainNameAsPrefix$installUserName /Add
}

InstallQuorumFailoverClustering