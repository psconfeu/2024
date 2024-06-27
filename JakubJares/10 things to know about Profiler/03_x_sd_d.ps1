function Get-Unicorn () { 
	1..10 | ForEach-Object { 
		Log-Message "Getting unicorns..."
		'🦄'
	}
}

function Log-Message ($message) {
	Start-Sleep -Milliseconds 100
	Write-Host $message
}

$trace = Trace-Script {
	Get-Unicorn
}

$trace.Top50SelfDuration | 
	Select-Object -First 10 | 
	Format-Table  SelfPercent, SelfDuration, Percent, Duration, File, Line, Text

$trace.Top50Duration | 
	Select-Object -First 10 | 
	Format-Table  SelfPercent, SelfDuration, Percent, Duration, HitCount, File, Line, Text