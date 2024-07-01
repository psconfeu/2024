$scriptBlock = {
    param ($number)
    Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 5)
    "Processed item $number on thread $([System.Threading.Thread]::CurrentThread.ManagedThreadId)"
}

# Start multiple thread jobs
$jobs = 1..10 | ForEach-Object {
    Start-ThreadJob -ScriptBlock $scriptBlock -ArgumentList $_
}
$jobs | Receive-Job -Wait -AutoRemoveJob


# whats about the throttle limit?

Start-ThreadJob -ScriptBlock $scriptBlock -ArgumentList $_ -ThrottleLimit 40

$jobs = 1..100 | ForEach-Object {
    Start-ThreadJob -ScriptBlock $scriptBlock -ArgumentList $_
}