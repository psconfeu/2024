$trace = Trace-Script {
	Write-Host 👋 PSConfEU
	Start-Sleep -Milliseconds 2024
}

$trace.Top50SelfDuration | 
	Format-Table SelfPercent, SelfDuration, Percent, Duration, File, Line, Text