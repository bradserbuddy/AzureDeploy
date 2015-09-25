function CreateMemcached()
{
    Write-Status "Creating Memcached 0..."
    CreateLinuxVmChecked $cloudServiceName $memcachedServerName0 $Basic_A2 $memcachedAvailabilitySetName $frontEndSubnetName $memcachedServerIP0

    Write-Status "Creating Memcached 1..."
    CreateLinuxVmChecked $cloudServiceName $memcachedServerName1 $Basic_A2 $memcachedAvailabilitySetName $frontEndSubnetName $memcachedServerIP1
}