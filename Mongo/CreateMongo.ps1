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
        -InstanceSize Large `
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
            Add-AzureEndpoint -Name "SSH" `
                                -Protocol tcp `
                                -PublicPort $port `
                                -LocalPort 22 |
                Update-AzureVM
    
<#  
    InitializeSSH $port
    UploadSSHPublicKey $port
    RunSSH $port "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10"
    RunSSH $port "echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list"
    RunSSH $port "sudo apt-get -y update"
    RunSSH $port "sudo apt-get -y install mongodb-org"
    RunSSH $port "sudo service mongod stop"

sudo fdisk /dev/sdc < fdiskCommands.txt
sudo mkfs -t ext4 /dev/sdc1
sudo mkdir /datadrive
sudo mount /dev/sdc1 /datadrive
sudo -i blkid | grep sdc1 | sed -r 's/.*(UUID=\"[0-9a-f-]{36}\").*/\1/' | sed 's/$/ \/datadrive ext4 defaults 0 2/' | sudo tee -a /etc/fstab
sudo umount /datadrive
sudo mount /datadrive
sudo cat /etc/mongod.conf | sed 's/dbpath=\/var\/lib\/mongodb/dbpath=\/datadrive\/mongodb/' | sudo tee /etc/mongod.conf
sudo mkdir -p /datadrive/mongodb
sudo chown -R mongodb:mongodb /datadrive/mongodb
sudo service mongodb start on startup

mongo
use admin
db.createUser({ user: "buddy", pwd: "&Tdmp4B.comINTC", roles: ["userAdminAnyDatabase"]})
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