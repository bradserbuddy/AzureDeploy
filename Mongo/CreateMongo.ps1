function CreateMongo()
{

    # SSH key\certificate info here:  http://azure.microsoft.com/en-us/documentation/articles/linux-use-ssh-key/
    #Add-AzureCertificate -ServiceName $dcCloudServiceName -CertToDeploy $sshLocalCertificatePath

    #$sshPublicKey = New-AzureSSHKey -PublicKey –Fingerprint $sshCertificateFingerprint –Path $sshRemotePublicKeyPath

    CreateMongoVm $mongoServerName1 20322

    CreateMongoVm $mongoServerName2 20422

    CreateLinuxVmChecked $dcCloudServiceName $mongoServerName3 $Basic_A1
}

function CreateMongoVm($serverName, $publicPort)
{
    #TODO: -SSHPublicKeys isn't adding the public key to authorized_keys, try ~.ssh/authorized_keys for $sshRemotePublicKeyPath?

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName

    if ($vm -eq $null)
    {
        CreateLinuxVm $dcCloudServiceName $serverName $Basic_A3

        # Can't chain because of -WaitForBoot
        Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
            Add-AzureDataDisk -CreateNew -DiskSizeInGB 200 -DiskLabel "Datadrive" -LUN 0 |
            Add-AzureDataDisk -CreateNew -DiskSizeInGB 10 -DiskLabel "Journal" -LUN 1 |
                Update-AzureVM
    }
    
<#  
    InitializeSSH $publicPort
    UploadSSHPublicKey $publicPort
    RunSSH $port "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10"
    RunSSH $port "echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list"
    RunSSH $port "sudo apt-get -y update"

    RunSSH $port "apt-get install mongodb-org=2.6.0 mongodb-org-server=2.6.3 mongodb-org-shell=2.6.3 mongodb-org-mongos=2.6.3 mongodb-org-tools=2.6.3"
    RunSSH $port "echo "mongodb-org hold" | sudo dpkg --set-selections"
    RunSSH $port "echo "mongodb-org-server hold" | sudo dpkg --set-selections"
    RunSSH $port "echo "mongodb-org-shell hold" | sudo dpkg --set-selections"
    RunSSH $port "echo "mongodb-org-mongos hold" | sudo dpkg --set-selections"
    RunSSH $port "echo "mongodb-org-tools hold" | sudo dpkg --set-selections"

    RunSSH $port "sudo service mongod start\stop"


In Mongo config (2.6):
comment out bind_ip
replSet = XX0 # the two-letter country code, followed by zero
add syncdelay = 20

In Mongo arbiter config (2.6):
comment out bind_ip
nojournal = true
noprealloc = true
smallfiles = true


mongo
use admin
rs.initiate()  # "local.oplog.rs is not empty on the initiating member.  cannot initiate." - this is a spurious error and can be ignored
db.createUser({ user: "buddy", pwd: "&Tdmp4B.comINTC", roles: ["userAdminAnyDatabase"]})
rs.add(<IP address:port of secondary>)
rs.addArb(<IP address:port of arbiter>)

exit #>
}


function InitializeSSH($port)
{
    # ssh.exe throws a warning when accepting the fingerprint
    try
    {
        & $sshExePath "$vmAdminUser@$dcCloudServiceName.$azureCloudServiceUrlPath" -p $port -i $sshLocalPrivateKeyPath --% -o StrictHostKeyChecking=no '"cd"'
    } catch {}
}

 
function UploadSSHPublicKey($port)
{
    $nameAndHost = "$vmAdminUser@$dcCloudServiceName.$azureCloudServiceUrlPath"

    & "C:\Program Files\TortoiseGit\bin\TortoiseGitPlink.exe" -ssh -P $port "sysadmin@b-v2-eus-dc.$($azureCloudServiceUrlPath)" -pw "$($vmAdminPassword)" "scp "$($nameAndHost)" "$($nameAndHost):~.ssh/authorized_keys""
}


function RunSSH($port, $command)
{
    & $sshExePath "$vmAdminUser@$dcCloudServiceName.$azureCloudServiceUrlPath" -p $port -i $sshLocalPrivateKeyPath "$command" 2>&1 > "C:\logfile.log" 
}