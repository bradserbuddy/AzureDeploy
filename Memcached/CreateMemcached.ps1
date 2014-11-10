function CreateMemcached()
{
    Write-Status "Creating Memcached 1..."
    CreateLinuxVmChecked $dcCloudServiceName $memcachedServerName1 $Basic_A2 $memcachedAvailabilitySetName

    Write-Status "Creating Memcached 2..."
    CreateLinuxVmChecked $dcCloudServiceName $memcachedServerName2 $Basic_A2 $memcachedAvailabilitySetName
}