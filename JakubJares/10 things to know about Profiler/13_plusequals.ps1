$trace1 = Trace-Script {
    $numbers = 1..10000
    $newNumbers = @()
    foreach ($number in $numbers) {
        # @() += 1 -> @(1) += 2 -> @(1,2) += 3 -> @(1,2,3)
        $newNumbers += $number
    }
}

$trace2 = Trace-Script {
    $numbers = 1..10000 
    $newNumbers = foreach ($number in $numbers) {
        $number
    }
}

$trace3 = Trace-Script {
    $numbers = 1..10000 
    $newNumbers = [System.Collections.Generic.List[int]]::new()
    foreach ($number in $numbers) {
        $newNumbers.Add($number)
    }
}

$trace4 = Trace-Script {
    $numbers = 1..10000 
    $newNumbers = [System.Collections.Generic.List[int]]::new(10000)
    foreach ($number in $numbers) {
        $newNumbers.Add($number)
    }
}

"`n+= $($trace1.StopwatchDuration)"
$trace1.Top50SelfMemory | Select -First 3 SelfMemory, SelfDuration, Text
"`n= foreach $($trace2.StopwatchDuration)"
$trace2.Top50SelfMemory | Select -First 3 SelfMemory, SelfDuration, Text
"`nlist, resized $($trace3.StopwatchDuration)"
$trace3.Top50SelfMemory | Select -First 3 SelfMemory, SelfDuration, Text
"`nlist, with capacity $($trace3.StopwatchDuration)"
$trace4.Top50SelfMemory | Select -First 3 SelfMemory, SelfDuration, Text