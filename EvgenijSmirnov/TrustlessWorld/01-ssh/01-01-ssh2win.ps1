<#
    
    PowerShell Conference EU 2024
    Antwerp, Belgium

    Evgenij Smirnov (@cj_berlin)

    Connecting to Systems in a Trustless World

    DEMO 01-01: Connecting to Windows using SSH

#>
#region env checks

# does Bob have a user profile on PSCONF-MS01?
# is Bob allowed to have a session on PSCONF-MS01?

#endregion
break
#region Bob is trying to remote in - run this from Linux
Enter-PSSession -HostName psconf-ms01.psconf.eu -UserName bob@psconf.eu 
Exit-PSSession
# does bob have a profile now?
#endregion
break
#region Optional: Craig is using key-based auth
# From WS01:
Enter-PSSession -HostName psconf-ms01.psconf.eu -UserName craig -KeyFilePath C:\sys\craigs_key
# From LX01:
Enter-PSSession -HostName psconf-ms01.psconf.eu -UserName craig -KeyFilePath ./craigs_key
#endregion
break
#region Root is remoting in - run this from Linux
Enter-PSSession -HostName psconf-ms01.psconf.eu -UserName root@psconf.eu
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
Exit-PSSession
# did we get an elevated token?
#endregion
