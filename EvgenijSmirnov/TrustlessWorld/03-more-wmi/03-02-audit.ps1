<#
    
    PowerShell Conference EU 2024
    Antwerp, Belgium

    Evgenij Smirnov (@cj_berlin)

    Connecting to Systems in a Trustless World

    DEMO 03-02: Audit settings language-independent via WMI

#>
#region setup
$dcTest = @'
& {
    $def = @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

namespace Audit
{
    public class Pol
    {
        [DllImport("advapi32.dll", CharSet = CharSet.Unicode, PreserveSig = true, SetLastError = true)]
        public static extern bool AuditEnumerateSubCategories(Guid AuditCategoryGuid, bool RetrieveAllSubCategories, [MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 3)] out Guid[] auditSubCategories, out uint numSubCategories);

        [DllImport("advapi32.dll", CharSet = CharSet.Unicode, PreserveSig = true, SetLastError = true)]
        public static extern bool AuditQuerySystemPolicy([MarshalAs(UnmanagedType.LPArray, SizeParamIndex = 1), In] Guid[] pSubCategoryGuids, uint dwPolicyCount, out IntPtr ppAuditPolicy);

        public static AUDIT_POLICY_INFORMATION QueryPolicy(Guid sc)
        {
            IntPtr ppAuditPolicy;
            if (AuditQuerySystemPolicy(new Guid[] {sc}, 1, out ppAuditPolicy)) {
                return ToStructure<AUDIT_POLICY_INFORMATION>(ppAuditPolicy);
            }
            return new AUDIT_POLICY_INFORMATION();
        }

        public static T ToStructure<T>(IntPtr ptr, long allocatedBytes = -1)
        {
            Type type = typeof(T).IsEnum ? Enum.GetUnderlyingType(typeof(T)) : typeof(T);
            if (allocatedBytes < 0L || allocatedBytes >= (long) Marshal.SizeOf(type))
            {
                return (T) Marshal.PtrToStructure(ptr, type);
            }
            throw new InsufficientMemoryException();
        }

        public struct AUDIT_POLICY_INFORMATION
        {
            public Guid sc;
            public uint ai;
            public Guid ca;
        }
    }
}
"@
    Add-Type -TypeDefinition $def -Language CSharp
    $regLegacyAudit = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name SCENoApplyLegacyAuditPolicy -EA SilentlyContinue
    $res = @{
        'LegacyDisabled' = ($regLegacyAudit.SCENoApplyLegacyAuditPolicy -eq 1)
    }
    $sc = @()
    $ns = 0
    $ca = [Guid]::Empty
    if ([Audit.Pol]::AuditEnumerateSubCategories($ca, $true, [ref]$sc, [ref]$ns)) {
        foreach ($c in $sc) {
            $pol = -1
            $pol = [Audit.Pol]::QueryPolicy($c)
            $res.Add($c.Guid,$pol.ai)
        }
    }

    $output = [PSCustomObject]$res | ConvertTo-Json -Compress
    if ($null -eq $PSSenderInfo) {
        New-ItemProperty -Path 'HKLM:\SOFTWARE' -Name 'PSConfEU.AuditPolicy' -PropertyType String -Value $output -Force -EA Stop
    } else {
        $output
    }
}
'@
$dcTestScriptBlock = [scriptblock]::Create($dcTest)
$ecmd = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($dcTest))
$dcTestCommand = ('cmd.exe /c "powershell.exe -EncodedCommand {0}"' -f $ecmd)
#endregion
#region processing
$tgtComp = 'psconf-dc01.psconf.eu'
$cred = Get-Credential -UserName 'root@psconf.eu' -Message 'Specify a user account'
$cimSO = New-CIMSessionOption –Protocol DCOM
$cimSess = New-CimSession -ComputerName $tgtComp -Credential $cred -SessionOption $cimSO
Invoke-CimMethod -ClassName Win32_Process -Name Create -Arguments @{'CommandLine' = $dcTestCommand} -CimSession $cimSess
#endregion