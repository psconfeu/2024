<#
    
    PowerShell Conference EU 2024
    Antwerp, Belgium

    Evgenij Smirnov (@cj_berlin)

    Connecting to Systems in a Trustless World

    DEMO 02-01: WMI vs. CIM/DCOM

#>
##region setup
$tgtComp = 'psconf-ms01.psconf.eu'
$iterations = 1000
$cred = Get-Credential -UserName 'root@psconf.eu' -Message 'Specify a user account'
$cimSO = New-CIMSessionOption –Protocol DCOM
$timer = New-Object System.Diagnostics.Stopwatch
#endregion
#region same thing many times
$timer.Start()
1..$iterations | ForEach-Object {
    $null = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $tgtComp -Credential $cred
}
$timer.Stop()
Write-Host ('{1}x retrieving ComputerSystem by WMI took {0:N} seconds' -f $timer.Elapsed.TotalSeconds, $iterations)

$timer.Restart()
$cimSess = New-CimSession -ComputerName $tgtComp -Credential $cred -SessionOption $cimSO
1..$iterations | ForEach-Object {
    $null = Get-CimInstance -ClassName Win32_ComputerSystem -CimSession $cimSess
}
$timer.Stop()
Write-Host ('{1}x retrieving ComputerSystem by CIM took {0:N} seconds' -f $timer.Elapsed.TotalSeconds, $iterations)
#endregion
break
#region different queries
$timer.Restart()
$wmiSvcs = Get-WmiObject -Class Win32_Service -ComputerName $tgtComp -Credential $cred
foreach ($svcName in $wmiSvcs.Name) {
    $null = Get-WmiObject -Query ('SELECT * FROM Win32_Service WHERE Name="{0}"' -f $svcName) -ComputerName $tgtComp -Credential $cred
}
$timer.Stop()
Write-Host ('WMI service enumeration took {0:N} seconds' -f $timer.Elapsed.TotalSeconds)


$timer.Restart()
$cimSess = New-CimSession -ComputerName $tgtComp -Credential $cred -SessionOption $cimSO
$cimSvcs = Get-CimInstance -ClassName Win32_Service -CimSession $cimSess 
foreach ($svcName in $cimSvcs.Name) {
    $null = Get-CimInstance -Query ('SELECT * FROM Win32_Service WHERE Name="{0}"' -f $svcName) -CimSession $cimSess
}
$timer.Stop()
Write-Host ('CIM/DCOM service enumeration took {0:N} seconds' -f $timer.Elapsed.TotalSeconds)
#endregion