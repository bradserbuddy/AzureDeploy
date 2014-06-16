function CreateMemcached()
{
    CreateLinuxVmChecked $dcCloudServiceName $memcachedServerName1 $Basic_A2

    CreateLinuxVmChecked $dcCloudServiceName $memcachedServerName2 $Basic_A2
}