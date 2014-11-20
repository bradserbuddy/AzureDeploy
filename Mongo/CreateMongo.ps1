function CreateMongo()
{

    # SSH key\certificate info here:  http://azure.microsoft.com/en-us/documentation/articles/linux-use-ssh-key/
    #Add-AzureCertificate -ServiceName $dcCloudServiceName -CertToDeploy $sshLocalCertificatePath

    #$sshPublicKey = New-AzureSSHKey -PublicKey –Fingerprint $sshCertificateFingerprint –Path $sshRemotePublicKeyPath

    Write-Status "Creating Mongo 1..."
    CreateMongoVm $mongoServerName1 20322

    Write-Status "Creating Mongo 2..."
    CreateMongoVm $mongoServerName2 20422

    Write-Status "Creating Mongo 3..."
    CreateLinuxVmChecked $dcCloudServiceName $mongoServerName3 $Basic_A1 $mongoAvailabilitySetName
}

function CreateMongoVm($serverName, $publicPort)
{
    #TODO: -SSHPublicKeys isn't adding the public key to authorized_keys, try ~.ssh/authorized_keys for $sshRemotePublicKeyPath?

    $vm = Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName

    if ($vm -eq $null)
    {
        CreateLinuxVm $dcCloudServiceName $serverName $Basic_A3 $mongoAvailabilitySetName

        # Can't chain because of -WaitForBoot
        Get-AzureVM -ServiceName $dcCloudServiceName -Name $serverName |
            Add-AzureDataDisk -CreateNew -DiskSizeInGB 200 -DiskLabel "Datadrive" -LUN 0 |
            Add-AzureDataDisk -CreateNew -DiskSizeInGB 10 -DiskLabel "Journal" -LUN 1 |
                Update-AzureVM
    }
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