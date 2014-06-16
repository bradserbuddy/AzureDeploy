function CreateMemcached()
{
    CreateLinuxVmChecked $dcCloudServiceName $memcachedServerName1 "Medium" #"Basic_A2"

    CreateLinuxVmChecked $dcCloudServiceName $memcachedServerName2 "Medium" #"Basic_A2"
}