# run this in commandline, it gets VSCode stuck
# if you are reading this, and I am panicking on stage
# please tell me :)
pwsh -NoProfile -NoExit {
    $trace = Trace-Script { . $profile } 
}
  
$trace.Top50SelfDuration | 
    Select-Object -First 1 | 
    Format-List Selfpercent, selfduration, path, line, module, function, text