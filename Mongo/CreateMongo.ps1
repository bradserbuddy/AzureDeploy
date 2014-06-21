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

    RunSSH $port "sudo apt-get -y install mongodb-10gen=2.4.10"
    RunSSH $port "echo "mongodb-10gen hold" | sudo dpkg --set-selections"
# 2.6 RunSSH $port "apt-get install mongodb-org=2.6.0 mongodb-org-server=2.6.0 mongodb-org-shell=2.6.0 mongodb-org-mongos=2.6.0 mongodb-org-tools=2.6.0"
# 2.6 RunSSH $port "echo "mongodb-org hold" | sudo dpkg --set-selections"
# 2.6 RunSSH $port "echo "mongodb-org-server hold" | sudo dpkg --set-selections"
# 2.6 RunSSH $port "echo "mongodb-org-shell hold" | sudo dpkg --set-selections"
# 2.6 RunSSH $port "echo "mongodb-org-mongos hold" | sudo dpkg --set-selections"
# 2.6 RunSSH $port "echo "mongodb-org-tools hold" | sudo dpkg --set-selections"

    RunSSH $port "sudo service mongodb stop"
# 2.6 RunSSH $port "sudo service mongod stop"

sudo fdisk /dev/sdc < fdiskCommands.txt
sudo mkfs -t ext4 /dev/sdc1
sudo mkdir /datadrive
sudo mount /dev/sdc1 /datadrive
sudo -i blkid | grep sdc1 | sed -r 's/.*(UUID=\"[0-9a-f-]{36}\").*/\1/' | sed 's/$/ \/datadrive ext4 defaults 0 2/' | sudo tee -a /etc/fstab
sudo umount /datadrive
sudo mount /datadrive

#sudo cat /etc/mongodb.conf | sed 's/dbpath=\/var\/lib\/mongodb/dbpath=\/datadrive\/mongodb/' | sudo tee /etc/mongodb.conf -- verify this is working
# 2.6 sudo cat /etc/mongod.conf | sed 's/dbpath=\/var\/lib\/mongodb/dbpath=\/datadrive\/mongodb/' | sudo tee /etc/mongod.conf
# replace $locationAbbrev
#sudo cat /etc/mongodb.conf | sed 's/\# replSet = setname/replSet = $locationAbbrev0/' | sudo tee /etc/mongodb.conf -- verify this is working

sudo mkdir -p /datadrive/mongodb
sudo chown -R mongodb:mongodb /datadrive/mongodb

    RunSSH $port "sudo service mongodb start"
# 2.6 RunSSH $port "sudo service mongod start"

mongo
use admin
rs.initiate()
db.addUser({ user: "buddy", pwd: "&Tdmp4B.comINTC", roles: ["userAdminAnyDatabase"]})
# 2.6 db.createUser({ user: "buddy", pwd: "&Tdmp4B.comINTC", roles: ["userAdminAnyDatabase"]})


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