<#
    
    PowerShell Conference EU 2024
    Antwerp, Belgium

    Evgenij Smirnov (@cj_berlin)

    Connecting to Systems in a Trustless World

    DEMO 01-02: Connecting to Linux using SSH

#>
break
#region run this from Windows or Linux
Enter-PSSession -HostName psconf-lx01.psconf.eu -UserName cj_berlin
Restart-Computer
Exit-PSSession
#endregion