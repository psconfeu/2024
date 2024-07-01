Import-module PoshRSJob

$scriptBlock = {
    param ($number)
    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 8)
    "Processed item $number on thread $([System.Threading.Thread]::CurrentThread.ManagedThreadId)"
}

1..10 | ForEach-Object {
    Start-RSJob -ScriptBlock $scriptBlock -ArgumentList $_ -Name "Job$_"
}

Get-RSJob | ForEach-Object {
    Write-Host "Job $($_.Name) - State: $($_.State)"
}

# Wait for all jobs to complete
Get-RSJob | Wait-RSJob

# Retrieve the results
$results = Get-RSJob | Receive-RSJob

# Clean up the jobs
Get-RSJob | Remove-RSJob

# Output the results
$results



# more advanced usage


$scriptBlock = {
    param ($number)
    Start-Sleep -Seconds 2
    write-host 'I should not be in the output'
    "Processed item $number on thread $([System.Threading.Thread]::CurrentThread.ManagedThreadId)"
}

$jobs = 1..100 | ForEach-Object {
    Start-RSJob -ScriptBlock $scriptBlock -ArgumentList $_ -Name "Job$_" -Throttle 10
}

# lets get the Information stream of the jobs
$Jobs.ChildJobs.Information

#region Steam spoiler
$jobs.Innerjob.streams.information
#endregion