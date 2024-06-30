$trace = Trace-Script { 
    throw "error!"
}

$trace.Top50SelfDuration | Select-Object -First 10