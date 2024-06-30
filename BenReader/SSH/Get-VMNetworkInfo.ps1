# Get all online VMs on device and retrieve their IPv4 Addresses
$vmNames = "debiandemo", "2025preview"
function Get-VMNetworkInfo {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$VMName
    )
    $VmIpAddr = foreach ($vm in $VMName) {
        $network = ( Get-VMNetworkAdapter -VMName $vm | Select-Object -ExpandProperty IPAddresses )[0]
        [pscustomobject]@{
            VMName    = $vm
            IPAddress = $network
        }
    }
    return $VmIpAddr
}

$VMs = Get-VM -Name $vmNames
$networkInfo = Get-VMNetworkInfo -VMName $VMs.Name
$networkInfo | ConvertTo-Json -Depth 20 | Out-File $PWD\VMNetworkInfo.json