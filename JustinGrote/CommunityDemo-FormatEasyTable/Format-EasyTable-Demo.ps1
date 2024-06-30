<#
EASYFORMAT!!!

It's here for now, it will probably move
https://gist.github.com/JustinGrote/8dcf827517021ac0210b65db7bceecf3
#>

#region Setup
Import-Module C:\Users\JGrote\Projects\EasyFormat\EasyFormat.psm1
$WarningPreference = 'SilentlyContinue'
$PSDefaultParameterValues['Get-AzActivityLog:MaxRecord'] = 30
Clear-Host
#endregion

#region Objects can be so Ugly
Get-AzActivityLog
#endregion

#region Better!
Get-AzActivityLog
| Format-Table EventTimestamp, OperationName, Status, Caller
#endregion

#region Even better!
Get-AzActivityLog
| Format-Table caller,
	eventtimestamp,
	operationname,
	status,
	@{
		Name = 'Method'
		Expression = { $_.httpRequest.Method }
	}
#endregion

#region Boss likes it a different way
Get-AzActivityLog
| Format-Table eventtimestamp, status, ResourceGroupName, OperationName, caller
#endregion

#region OK now lets filter this
Get-AzActivityLog
| Format-Table eventtimestamp, status, ResourceGroupName, OperationName, caller
| Where-Object Status -eq 'Succeeded'
#endregion

#region Huh? What? Why no Results?
Get-AzActivityLog
| Format-Table eventtimestamp, status, ResourceGroupName, OperationName, caller
| Get-Member
| Foreach-Object TypeName
#THIS SUCKS!!!!
#endregion

#region Format File?
#https://github.com/JustinGrote/ModuleFast/blob/main/ModuleFastSpec.Format.ps1xml

#THIS ALSO SUCKS!!!
#endregion

#region SNOVER TO THE RESCUE
#https://devblogs.microsoft.com/powershell/psstandardmembers-the-stealth-property/

#Limited to just basic properties though
#endregion

#region Enter: EasyTable

Get-AzActivityLog
| Format-EasyTable eventtimestamp, status,
	ResourceGroupName, OperationName, caller

#Format-Table syntax you know, but wait!

Get-AzActivityLog

Get-AzActivityLog
| Get-Member
| FOreach-Object TypeName

Get-AzActivityLog
| Where-Object Status -eq 'Succeeded'
#It persists!

#We can also name it!
Get-AzActivityLog
| Format-EasyTable -ViewName BossMode eventtimestamp, status,
	ResourceGroupName, OperationName, caller

#endregion

#region Supports Calculated Properties (GroupBy is really close)
Get-AzActivityLog
| Format-EasyTable -ViewName WithMethod -Property eventtimestamp,
	operationname,
	status,
	@{
		N = 'Method'
		E = { $_.httpRequest.Method }
	}

Get-AzActivityLog | Format-Table -View   #Intellisense here!
#endregion

#region What if I want the formatting XML?
Get-AzActivityLog
| Format-Table -Wrap -Property eventtimestamp,
	operationname,
	status,
	@{
		N = 'Method'
		E = { $_.httpRequest.Method }
	}
| ConvertFrom-Format
| ConvertTo-FormatXml

#BUT THIS DOESNT WORK! (Thanks Bruce Payette! This is way easier.)

#endregion