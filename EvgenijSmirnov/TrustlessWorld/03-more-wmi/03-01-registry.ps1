<#
    
    PowerShell Conference EU 2024
    Antwerp, Belgium

    Evgenij Smirnov (@cj_berlin)

    Connecting to Systems in a Trustless World

    DEMO 03-01: Registry via WMI

#>
#region setup
$tgtComp = 'psconf-ms01.psconf.eu'
$cred = Get-Credential -UserName 'root@psconf.eu' -Message 'Specify a user account'
$cimSO = New-CIMSessionOption –Protocol DCOM
$cimSess = New-CimSession -ComputerName $tgtComp -Credential $cred -SessionOption $cimSO
#endregion
break
#region get registry value
$regPath = @{
    'hDefKey'     = [uint32]'0x80000002'  # HKLM
    'sSubKeyName' = 'SOFTWARE\Microsoft\Virtual Machine\Guest\Parameters'
    'sValueName'  = 'PhysicalHostNameFullyQualified'
}
$args = @{
    'Namespace'  = 'root/cimv2'
    'ClassName'  = 'StdRegProv' 
    'MethodName' = 'GetStringValue' 
    'Arguments'  = $regPath
}

$regV = Invoke-CimMethod -CimSession $cimSess @args
if ($regV.ReturnValue -eq 0) {
    Write-Host $regV.sValue
}
#endregion