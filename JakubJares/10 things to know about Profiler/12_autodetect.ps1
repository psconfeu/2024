$trace = Trace-Script { 
    "hello"
    Get-PSBreakpoint | Remove-PSBreakpoint
}visua