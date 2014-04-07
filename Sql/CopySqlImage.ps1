function CopySqlImage()
{
    # From http://blogs.msdn.com/b/piyushranjan/archive/2013/06/01/copying-captured-vm-image-in-azure-iaas.aspx

    $SrcStorageAccount="portalvhds8kjbnbjxsbfrm";

    $sqlImage = (Get-AzureVMImage | where {$_.Label -like "SQLImage"} | sort PublishedDate -Descending)[0]


    $VHDContainerName = $sqlImage.MediaLink.Segments[$sqlImage.MediaLink.Segments.Length - 2];
    $ImageContainerName = $VHDContainerName;

    $SrcImageName = $sqlImage.ImageName;
    $SrcImageVHD = $sqlImage.MediaLink.Segments[$sqlImage.MediaLink.Segments.Length - 1].TrimEnd("/");

    $DestImageName = $SrcImageName;
    $DestImageVHD = $DestImageName + ".vhd";


    $SrcStgKey = (Get-AzureStorageKey -StorageAccountName $SrcStorageAccount).Primary;
    $SrcStorageContext=New-AzureStorageContext -StorageAccountName $SrcStorageAccount -StorageAccountKey $SrcStgKey -Protocol Https;

    $DestStgKey = (Get-AzureStorageKey -StorageAccountName $storageAccountName).Primary;
    $DestStorageContext=New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $DestStgKey -Protocol Https;


    $sqlStorageBlob = $null
    try
    {
        $sqlStorageBlob = Get-AzureStorageBlob -Context $DestStorageContext -Blob $DestImageVHD -Container $ImageContainerName.TrimEnd("/")
    }
    catch { }

    if ($sqlStorageBlob -eq $null)
    {
        $ImageBlob = Start-CopyAzureStorageBlob -SrcContext $SrcStorageContext -SrcBlob $SrcImageVHD -SrcContainer $VHDContainerName.TrimEnd("/")  -DestContext $DestStorageContext -DestContainer $ImageContainerName.TrimEnd("/") -DestBlob $DestImageVHD;

        $ImageBlob | Get-AzureStorageBlobCopyState -WaitForComplete;

        $mediaLocation = $DestStorageContext.BlobEndPoint + $ImageContainerName + $DestImageVHD
        Add-AzureVMImage -ImageName "$DestImageName$storageAccountName" -OS "Windows" -MediaLocation $mediaLocation
    }
}