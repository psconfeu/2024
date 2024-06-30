$trace = Trace-Script {
    $numbers = 1..10000
    $newNumbers = @()
    foreach ($number in $numbers) {
        # @() += 1 -> @(1) += 2 -> @(1,2) += 3 -> @(1,2,3)
        $newNumbers += $number
    }
}

$trace.Top50SelfMemory | 
    Select-Object -First 10 | 
    Format-Table SelfMemoryPercent, SelfMemory, SelfGc, HitCount, File, Text


 