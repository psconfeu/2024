#region HEY BEN UPDATE THESE BEFORE YOU START
$localVMs = Get-Content .\SSH\VMNetworkInfo.json -Raw | ConvertFrom-Json
$remoteUser = "administrator"
$homeAddr = ""
$homeUser = ""
$debianIpAddr = ""
$debianUser = ""
$jaap = @'
                                 █████████████████████                                              
                                ▓███████████████████████                                            
                               ▓▓████████▓▓▓██████████████                                          
                              ▓▒▓▓██████▓██▓▓███████████████                                        
                             ▓▓▓▓▓▓█▓█▓█▓▓▓▓██████████████████                                      
                           █▓▓▓▓▓▓▓▓▓▓▓▓█▓██▓██████████████████                                     
                          ███▓▓▓▓▒▒▓▒▒▓▒▓▓▓▓▓▓███████████████████                                   
                         ████▓▒░░░░░░░▒▒░░░░▒▒▒▒▓▓████████████████                                  
                        ███▓▒░░░░░░░░░░░░░░░░░░▒▒▓▓▓▓▓█████████████                                 
                       ███▒░░░░░░░░░░░░░░░░░▒░░▒▒▒▓▓▓▓▓▓▓████████████                               
                      ██▓▓░░░░░░░░░   ░░░░░░░░░░▒▒▓▓▓▓▓▓▓▓███████████▓                              
                     ▓██▒░░░░░░   ░░    ░░░░░░░░░▒▒▓▓▓▓▓▓▒████████████                              
                     ███▒░░░░░░   ░░    ░░▒░░░░▒░▒▒▒▓▓▓▓▓▓▒███████████                              
                    ▓██▓░░░░░░░   ░▒    ░░▒░░░░░▒▒▒▒▓▓▓▓▓▓▓▓███████████                             
                    ███▒░░▒░░░    ░▒░  ░ ░▓░░░░░▓▒▒▒▓▓▓▓▓▓▓▓███████████                             
                    ██▓▓░░░░░░    ░▓▒░ ░ ░▓░░░░░▓▒▒▒▓▓▓▓▓▓▓████████████                             
                     ██▓▒▒░▒▒░    ░▓▓░  ▒▓▒░░░░░▒▓▒▒▓▓▓▓▓██████████████                             
                      ▓▓▓▒▒▓▓▒▒░░░▓█▓░  ▒▓▒▒▓▓▓█▓▓▓▓██▓▓██████████████▓                             
                      ▓▓▓▓░▒███▓▓▓▓▓░ ░░░████▓██▓█▓███▓▓▓▓█████████▓▓▓▓▓                            
                    ▒░▒▓▓██▓▒▒▒▓▓█▒░░░░░▒▓▓█▒ ▒▒█▓▓██▓▒▒▓▓▓███████▓▓▓▓▒▒                            
                    ░░░▓░▒▓█▓▓████▒░░░░▒▓▓▓██▓▒▓▓▓██▓▓▒▒▓▓▓▓██████▓▒▒▓▒▒                            
                    ░░░▓█▓▒░░▒▒░█▓░░░░░▒▓▓▓▒█▒ ▓░░░▒▒▒▓▓███▓██████▒▒▒▓▓▒                            
                    ░ ░░░░░░░ ▒▓░▒░░░░░▒▓▓▓▓▓▓░░░░░░░░▒▒▓▓▓█▓████▓▒▒▒▒▓▒                            
                     ░  ░░  ▒▒░  ▒░░░░░▒▓▓▓▒░▒▓░  ░░░▒▒▒▓▓▓█▓█▓██▓▒▒▒▓▓                             
                     ░░░░░░░░   ░░░░░░▒▓▓▓▓▓▒░░░▒ ░░░▒▒▓▓▓▓███▓█▓▓▓▓▓▓                              
                      ░░░░░░   ░░░░░░░░▒▓▓▓▓▓▒░░░▒░░░▒▒▒▓▓████▓▓▒▓▓▒▒                               
                      ░░░░░▒░░░░░░▒▒░░▒▓▓▓▓█▓▒░░░░░░░▒▓▒▓▓███▓▓▓▓▒▓▓                                
                        ░░░░░░░░░▓░░░▒░░░▓▒▓▓▓▒▒░▒░░░░▓▒▓▓██████▓▓                                  
                         ░░░░░▒▓███████████████▓░░░░░▒▒▒▓▓▓▓█████                                   
                         ░░░░▒███▓░░░░░░ ░░░▒███▓░░ ░▓▒▒▓▓▓█████▓                                   
                          ░░░▓████▓▒▒▒▒▒▓████████▒░░▒▓▒▓▓▓▓▓███▓▓                                   
                          ░░▒▓▓████████████████▒█▓▒▒▓▒▒▓▓▓▓████▓                                    
                           ░░░░█▒▓░░▓███▒▓░▒░▓▓▒▒▓▒▓▓▓▓▓▓▓▓▓▓▓▓▓                                    
                             ░░▓░▒░░░▒█░░▒░▒░▒▓▒░▓▒▓▓▓▓▓▓▓▓▓▓▓▓██                                   
                              ░░░░░░░▒▓░░░░░░░▓▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▓▓                                 
                               ░░░░░░▒▓░  ░░░▒▓▒▓▓▓▓▓▓▓▓▓▓▒▒▒▓▓█▒▒▓▓                                
                                ░░░░░░░░ ░▒░░▒▓▓▓▓▓▓▓▓▓▓▒▒▒▒▒▓▓▒▒▓▓▓▓                               
                                ░░░░░░░▒░░▒▒▒▓▓▓▓▓▓▓▓▓▒▒▒▒▒▒▒▒▒▒▒▓▒▓▓▓                              
                                ▒░░▒▒▒▒▒▒▒▒▒▓▓▓▓▓▓▓▓▒▒▒░░░░▒░░▒▒▒▒▒▒▒▓▓                             
                                ░░░░░░░░░▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░░▒▒▒▒▒▒▒▒▒▓▓▓                           
                               ░░▒░░░░░░░░░░░░░▒▒▒▒░░░░░░░░▒▒▒▒▒▒▒▒░▒▒▓▓▓▓▓                         
                              ░░░▓░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▒▒▒░░▒▒▒▒▓▒▒▒▒▒                     
                             ░░░░▓▓░░░░░░░░░░░░░░░░░  ░░░▒▒▒▒▒▒▒▒▒░░░░▒░▒▒▒▒▒▒▒▒▒▒▒                 
                            ░▒▒▒░▒█░░░░░     ░░░░░ ░░▒░░▒▒▒▒▒▒▒▒▒░░░░▒▒░░░▒▒░░░░░░▒▒▒▓▓▓            
                         ░░░▒▓▓▒▒▒▓▓░░░░    ░░░░░░▒▓▓▒▒░▒▒▒▒▒▒▒▒░░░░░▒▒░░░░░░░░░░░░░░░▒▒▓▓▓▓        
                     ░░░░░░░░▒▒▒▒▓▓█▒░░░░░     ░░░▓▒▒▒▒░░▒▒▒░▒▒░░░░░░▒░░░░░░░░░░░░░░░░░░▒▒▓▓▓▓▓     
                 ▒░░░░░░░░░  ▒▓▒░▒▓█▓▒░░░░░░   ░▒▓▓▒▒▒▒░░░░░▒▒░░░░░░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▓▓▓▓▓  
             ▒░░░░░░░░░░░░░░░▓▓░░░░▒▒▒▒░░░░░  ░▒▒▒▒▒▒▒▒░░░░░░░░░░░░░░▒░░░░░░░░░░░░░░░░░░░░░▒▒▒▒▒▒▓▓▓
          ▒░░░░░░░░░░░░░░░░▒▓▓░ ░░░░░░░░▒░    ░▒▒▒▒▒░▒░░░░░░░░░░░▒▒░░▒░░░░░░░░░░░▒░░░░░░░░░ ░░░▒▒▒▒▒
        ░░░░░░░░░░░░░░░░░░▒▒░░░░ ░░░░░░░░▓░   ░░░░▒▒▒░░░ ░░░░░░░░░░▒▒▒░░░░░░░░░░░░░░░ ░░░░░░░░░░░░▒▒
       ░░░░░░░░░░░░░░░░░░░░░░░░░░  ░░ ░░░▒▒░  ░ ░▒▓░░░░ ░░░░░░░░ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░▒
      ░░░░░░░░░░░░░░░░░░░░░         ░▒░░░░▒░  ░▒█▓░░░  ░░░░ ░░░ ░░░  ░░ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░
     ░░░░░░░░░░░░░░░░░░░░░░░░░      ░░░░░░░▒░░▓▓▒░░░ ░░░░  ░░  ░░  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
    ░░░░░░░░░░░░ ░░░░ ░░░░░░░░      ░ ░░░░░░▓▓▒░░  ░░░░  ░░  ░░░ ░░░ ░░ ░░░ ░░░░░░░░░░░░░░░░░░░░░░▒▒
   ░░░░░ ░░░░░░░░░░░░░░░░░░░░░░░░░  ░░░░ ▒▒▒░░   ░░░  ░░░  ░░░ ░░░ ░░ ░░░ ░░░░░░░░░░░░░░░ ░░░░░░░░░▒
   ░░░░ ░░░░░░░░░░░░░░░░░░░░░░  ░░     ░▒▒░░  ░░░░  ░░░  ░░░ ░░░ ░░░░░░░░░░░░░░░░░░░░░░ ░░░░░░░░░░░▒
  ░░░░░░ ░░░░░░░░░░░░░  ░░  ░░░░░░░░░░░▒░  ░░░░   ░░░ ░░░  ░░░ ░░░ ░░░░░░░░░░░ ░░░░░░ ░░░░░░░░░░░░░░
 ░░░░░░░░ ░░░░░ ░░░ ░░░░░  ░  ░░░░░░░░░░░░░░   ░░   ░░  ░░░  ░░░ ░░░░░░░░░░ ░░░░░░ ░░░░░░░░░░░░░░░░░
 ░░░░░░░░ ░░░░ ░░░░░░░  ░░░░░    ░░ ░░░ ░  ░░░░  ░░░ ░░░  ░░░ ░░░░ ░░░░░░░░░░░░░░░░░░░░░░ ░░░░░░░░░░
 ░░░░░░░░░ ░░░░░░░░░░░ ░░░   ░   ░░░░░       ░░░   ░░  ░░░  ░░░ ░░░░░░░ ░░░░ ░░░░░░ ░░░ ░░░░░░▒░░░░░
 ░░░░░░░░░░░░░░░░░░░░░░░ ░░░░░   ░ ░░   ░░░░░  ░░░  ░░░  ░░  ░░░░░ ░░░░░░░░░░░ ░░░░ ░░░░░░░░░▒▒░░░░░
'@
#endregion

#region install, enable and configure ssh server

# is it already installed?
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# install required components
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

#region set up service auto start and start service, configure firewall
Set-Service -Name sshd -StartupType 'Automatic'
Start-Service sshd

# default firewall policy is installed with the OpenSSH.Server capability, we need to change the profile to "any"
Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" | Set-NetFirewallRule -Profile "any"

# we might want ping as well
Get-NetFirewallRule -Name "CoreNet-Diag-ICMP4-EchoRequest-In" | Set-NetFirewallRule -Profile "any" -Enabled true

#region firewall causing problems? shoot it in the face
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled false
#endregion

#region from scratch if needed
$fwParams = @{
    Name        = "OpenSSH-Server-In-TCP"
    DisplayName = "OpenSSH Server"
    Enabled     = $true
    Direction   = "Inbound"
    Protocol    = "TCP"
    Action      = "Allow"
    LocalPort   = 22
}
New-NetFirewallRule @fwParams
#endregion
#endregion


#region configure ssh system-wide configuration.
# choose how to connect to server and open sshd config file
notepad "$($env:programdata)\ssh\sshd_config"

# once you have configured the sshd_config file, update the firewall and restart the sshd service
$newPort = 44 #LITERALLY ANYTHING OTHER THAN THE DEFAULT
Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" | Set-NetFirewallRule -LocalPort $newPort
Get-service sshd | Restart-Service
#endregion

#endregion

#region let's use PowerShell as the default shell
#windows
$regParams = @{
    Path         = "HKLM:\SOFTWARE\OpenSSH"
    Name         = "DefaultShell"
    Value        = "C:\Program Files\PowerShell\7\pwsh.exe"
    PropertyType = "String"
    Force        = $true
}
New-ItemProperty @regParams

#linux
cat /etc/shells
chsh -s /usr/bin/pwsh

#mac
cat /etc/shells
chsh -s /usr/local/bin/pwsh

# restart sshd service
Get-service sshd | Restart-Service

#endregion

#region passwords suck, lets be better than that

# generate a new key pair (rsa is default - be better than that)
ssh-keygen -t ed25519

#region secure the private key
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519
#endregion

#region copy the public key to the server (standard user)
$pubKey = Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
$remotePowershell = "powershell New-Item -Force -ItemType Directory -Path $env:USERPROFILE\.ssh; Add-Content -Force -Path $env:USERPROFILE\.ssh\authorized_keys -Value '$pubKey'"
ssh $remoteUser@$remoteIpAddr $remotePowershell
#endregion

#region copy the public key to the server (admin)
$pubKey = Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
$remotePowershell = "powershell Add-Content -Force -Path $env:ProgramData\ssh\administrators_authorized_keys -Value '''$pubKey''';icacls.exe ""$env:ProgramData\ssh\administrators_authorized_keys"" /inheritance:r /grant ""Administrators:F"" /grant ""SYSTEM:F"""
ssh $remoteUser@$remoteIpAddr $remotePowershell
#region cleaner admin code for review
Add-content -Force -Path $env:ProgramData\ssh\administrators_authorized_keys -Value $pubKey
icacls.exe "$env:ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"
#endregion
#endregion

#region make sure to disable password authentication in sshd_config!
#endregion

#endregion

#region PSRemoting

# does our remote machine support it? (yes. yes it does.)
(Get-Command New-PSSession).ParameterSets.Name

#region copy the command into sshd_config on remote machine

#windows
Subsystem powershell c:/progra~1/powershell/7/pwsh.exe -sshs -nologo

#linux
Subsystem powershell /usr/bin/pwsh -sshs -nologo
# (make pwsh default shell on linux: chsh -s /usr/bin/pwsh)

#mac
Subsystem powershell /usr/local/bin/pwsh -sshs -nologo

# restart sshd service
Get-service sshd | Restart-Service
#endregion

#region test the connection
$session = New-PSsession -HostName $remoteIpAddr -UserName $remoteUser
Enter-PSSession -Session $session

#region do something fun to entertain the crowd
$sb = {
    New-Item -Path "C:\jaap.txt" -ItemType File -Force
    Add-Content -Path "C:\jaap.txt" -Value $using:jaap
}
Invoke-Command -Session $session -scriptBlock $sb
invoke-command -Session $session -ScriptBlock {get-content -raw C:\jaap.txt}
#endregion
#endregion
#endregion

#region Port Tunnelling
#region run nginx on remote machine, tunnel port 80 to local machine
ssh -L 80:$($debianIpAddr):80 $debianUser@$debianIpAddr -p 44
#endregion

#region access service running on a remote service...
ssh -L 42069:192.168.1.1:80 $homeUser@$homeAddr -p 44
#endregion
#endregion