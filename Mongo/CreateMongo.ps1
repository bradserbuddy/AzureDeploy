function CreateMongo()
{
    $linuxImageName = (Get-AzureVMImage | where {$_.Label -like "Ubuntu Server 12.04.4 LTS"} | sort PublishedDate -Descending)[0].ImageName

    # SSH key\certificate info here:  http://azure.microsoft.com/en-us/documentation/articles/linux-use-ssh-key/
    Add-AzureCertificate -ServiceName $dcCloudServiceName -CertToDeploy $sshLocalCertificatePath

    $sshPublicKey = New-AzureSSHKey -PublicKey –Fingerprint $sshCertificateFingerprint –Path $sshRemotePublicKeyPath

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $mongoServerName1

    if ($vm -eq $null)
    {
        CreateMongoVM $mongoServerName1 20322
    }

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $mongoServerName2

    if ($vm -eq $null)
    {
        CreateMongoVM $mongoServerName2 20422
    }
}

function CreateMongoVM($serverName, $port)
{
    #TODO: -SSHPublicKeys isn't adding the public key to authorized_keys, try ~.ssh/authorized_keys for $sshRemotePublicKeyPath?

    New-AzureVMConfig `
        -Name $serverName `
        -InstanceSize A3 `
        -ImageName $linuxImageName `
        -MediaLocation "$storageAccountContainer$serverName.vhd" `
        -AvailabilitySetName $azureAvailabilitySetName `
        -DiskLabel "OS" | 
        Add-AzureProvisioningConfig `
            -Linux `
            -LinuxUser $vmAdminUser `
            -Password $vmAdminPassword `
            -NoSSHEndpoint `
            -SSHPublicKeys $sshPublicKey |
            Set-AzureSubnet `
                -SubnetNames $frontSubnetName |
				New-AzureVM `
					-ServiceName $dcCloudServiceName `
                    -WaitForBoot

    # Can't chain because of -WaitForBoot
    Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
        Add-AzureDataDisk -CreateNew -DiskSizeInGB 200 -DiskLabel "Mongo" -LUN 0 |
            Update-AzureVM
    
<#  
    InitializeSSH $port
    UploadSSHPublicKey $port
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
db.addUser({ user: "buddy", pwd: "&Tdmp4B.comINTC", roles: ["userAdminAnyDatabase"]})
# 2.6 db.createUser({ user: "buddy", pwd: "&Tdmp4B.comINTC", roles: ["userAdminAnyDatabase"]})


On M1:
workaround for https://bugs.launchpad.net/ubuntu/+source/walinuxagent/+bug/1308974 :
	var x = rs.conf()
	replace hostname with IP in x
	rs.initiate(x)
	rs.add(IP address)
rs.initiate()
rs.add(M2 host name)
rs.conf()
rs.status()

exit #>
}


function InitializeSSH($port)
{
    # ssh.exe throws a warning when accepting the fingerprint
    try
    {
        & $sshExePath "$vmAdminUser@$dcCloudServiceName.cloudapp.net" -p $port -i $sshLocalPrivateKeyPath --% -o StrictHostKeyChecking=no '"cd"'
    } catch {}
}

 
function UploadSSHPublicKey($port)
{
    $nameAndHost = "$vmAdminUser@$dcCloudServiceName.cloudapp.net"

    & "C:\Program Files\TortoiseGit\bin\TortoiseGitPlink.exe" -ssh -P $port "sysadmin@b-v2-eus-dc.cloudapp.net" -pw "$($vmAdminPassword)" "scp "$($nameAndHost)" "$($nameAndHost):~.ssh/authorized_keys""
}


function RunSSH($port, $command)
{
    & $sshExePath "$vmAdminUser@$dcCloudServiceName.cloudapp.net" -p $port -i $sshLocalPrivateKeyPath "$command" 2>&1 > "C:\logfile.log" 
}