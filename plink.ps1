Function Invoke-SSHCommands {
 Param($Hostname,$Username,$Password, $CommandArray,
  $PlinkAndPath,
  $ConnectOnceToAcceptHostKey = $true)
 
 $Target = $Username + '@' + $Hostname
 $plinkoptions = "-ssh $Target -pw $Password"
 
 #Build ssh Commands
 $CommandArray += "exit"
 $remoteCommand = ""
 $CommandArray | % {
  $remoteCommand += [string]::Format('{0}; ', $_) 
 }
 
 #plist prompts to accept client host key. This section will
 #login and accept the host key then logout.
 if($ConnectOnceToAcceptHostKey)
 {
  $PlinkCommand  = [string]::Format('echo y | & "{0}" {1} exit',
   $PlinkAndPath, $plinkoptions )
  #Write-Host $PlinkCommand
  $msg = Invoke-Expression $PlinkCommand
 }
 
 #format plist command
 $PlinkCommand = [string]::Format('& "{0}" {1} "{2}"',
  $PlinkAndPath, $plinkoptions , $remoteCommand)
 
 #ready to run the following command
 #Write-Host $PlinkCommand
 $msg = Invoke-Expression $PlinkCommand
 $msg
}
 
$PlinkAndPath = "C:\Program Files (x86)\PuTTY\plink.exe"
$Username = "remoteshell"
$Password = "pa$$w0rd"
$Hostname = "Linuxhost"
 
$Commands = @()
$Commands += "ls"
$Commands += "whoami"
 
Invoke-SSHCommands -User $Username  `
 -Hostname $Hostname `
 -Password $Password `
 -PlinkAndPath $PlinkAndPath `
 -CommandArray $Command