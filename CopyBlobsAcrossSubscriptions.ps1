// http://blogs.msdn.com/b/igorpag/archive/2015/02/19/register-and-azure-vm-image-from-vhds.aspx

Select-AzureSubscription "BizSpark Plus" 
 
$blobName = "Buddy-WebFrontend-R6-os-2015-05-13.vhd"
$containerName = "images"


 
$srcStorageAccount = "baue"
$srcStorageKey = ""
 
$srcUri = "https://" + $srcStorageAccount + ".blob.core.windows.net/" + $containerName + "/" + $blobName

$destStorageAccount = "beuw2"
$destStorageKey = ""
 
$srcContext = New-AzureStorageContext  –StorageAccountName $srcStorageAccount `
                                        -StorageAccountKey $srcStorageKey  
 
$destContext = New-AzureStorageContext  –StorageAccountName $destStorageAccount `
                                        -StorageAccountKey $destStorageKey  
 
 
$blobCopy = Start-AzureStorageBlobCopy -srcUri $srcUri `
                                    -SrcContext $srcContext `
                                    -DestContainer $containerName `
                                    -DestBlob $blobName `
                                    -DestContext $destContext


$status = $blobCopy | Get-AzureStorageBlobCopyState -Blob $blobName -Container $containerName 
$status 
                                    
While ($status.Status -eq "Pending") {
    $status = $blobCopy | Get-AzureStorageBlobCopyState -Blob $blobName -Container $containerName 
    Start-Sleep 10
    $status
}