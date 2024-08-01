<#
.SYNOPSIS
    This script retrieves PowerShell command history from PSReadline console host history files.

.DESCRIPTION
    This script searches for PSReadline console host history files in user profiles and system profiles,
    and then outputs the content of those files to display PowerShell command history.

.EXAMPLE
    .\Get-PsHistory.ps1
    Retrieves and displays PowerShell command history from PSReadline console host history files.

.NOTES
    Author: Miriam Wiesner, @miriamxyra
#>

$UserHistory = @(Get-ChildItem "C:\Users\*\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt").FullName;

$UserHistory += @(Get-ChildItem "c:\windows\system32\config\systemprofile\appdata\roaming\microsoft\windows\powershell\psreadline\consolehost_history.txt" -ErrorAction SilentlyContinue).FullName;

foreach ($Item in $UserHistory) {
    if ($Item) {
        Write-Output ""
        Write-Output "###############################################################################################################################"
        Write-Output "PowerShell history: $item"
        Write-Output "###############################################################################################################################"
        Get-Content $Item
    }
}