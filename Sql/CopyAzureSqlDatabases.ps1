$sqlAzureConnectionString = "Server=tcp:tx1hm2adry.database.windows.net,1433;User ID=azurebuddycom@tx1hm2adry;Password=sdbl,DTP;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;"

$vmConnectionString = "Server=tcp:b-v2-wus-sql.cloudapp.net,1;User ID=sa;Trusted_Connection=False;Encrypt=True;Connection Timeout=30;Password=sdbl,DTP;TrustServerCertificate=True"

.\Backup-SQLAzureDB.ps1 -ConnectionString $sqlAzureConnectionString `
     -DatabaseName "buddy-v2-us-4-2014-2-20-10-10" -OutputFile “C:\BuddyObjects.bacpac”

.\Backup-SQLAzureDB.ps1 -ConnectionString $sqlAzureConnectionString `
     -DatabaseName "buddy-v2-us-queue" -OutputFile “C:\buddy_queue.bacpac”

.\Restore-SQLAzureDB.ps1 -ConnectionString $vmConnectionString
    -DatabaseName “BuddyObjects” -InputFile “C:\BuddyObjects.bacpac”

.\Restore-SQLAzureDB.ps1 -ConnectionString $vmConnectionString
    -DatabaseName “buddy_queue” -InputFile “C:\buddy_queue.bacpac”
