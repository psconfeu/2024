# Or better pwsh -NoExit, to ensure we run like first time every time
# but it does not play nice with VSCode.
Install-Module powershell-yaml
Get-Module powershell-yaml | Remove-Module
$trace = Trace-Script { 
	Import-Module powershell-yaml
}

$trace.Top50SelfDuration | 
	Select-Object -First 10 | 
	Format-Table SelfPercent, SelfDuration, HitCount, File, Text