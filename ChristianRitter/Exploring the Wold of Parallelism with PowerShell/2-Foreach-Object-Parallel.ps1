#region Foreach-Object -Parallel Basics

# we have to use the pipeline to use the -Parallel parameter

1..10 | ForEach-Object -Parallel {
    $_
} -ThrottleLimit 5


# the Pipeline can sometimes a bit slow
Measure-Command -Expression {
    1..4| ForEach-Object -Parallel {
        Start-Sleep 1
    } -ThrottleLimit 4
}

Measure-Command -Expression {
    1..80| ForEach-Object -Parallel {
        Start-Sleep 1
    } -ThrottleLimit 80
}

Measure-Command -Expression {
    1..1kb| ForEach-Object -Parallel {
        Start-Sleep 1
    } -ThrottleLimit 1kb
}

# but we have to wait till the threads are finished, but:
# we can also create Jobs, so FO-P is not taking our jobs ;-)

# basic creation of Jobs via ForEach-Object -Parallel
$Jobs = 1..8 | ForEach-Object -Parallel {
    Start-Sleep 1
} -ThrottleLimit 4 -asjob


# lets inspect them
$jobs
$jobs.ChildJobs


# are they really running in parallel?
# due to throttling, we can see that the first 4 jobs are running in parallel
($jobs.Childjobs.PSBeginTime)

# but do they really run in parallel - or starting at least in the exact same moment in time and finishing?
($jobs.Childjobs.PSBeginTime).Millisecond


# the execution time is the same for all jobs, or?
$(foreach($jobElement in $jobs.ChildJobs){
    $jobElement | Select-Object -Property name, @{Name='Duration';Expression={$PSItem.PSEndTime - $PSItem.PSBeginTime}}
}) | Measure-Object -Property Duration -Maximum | Select-Object -Property Maximum


#endregion

#region use outside function to add inside of a scriptblock
function Get-Applause {
    return "applause"
    
} 

$applauseFunction = ${function:Get-Applause}.ToString()
1..10 | foreach-object -Parallel {
    ${function:Get-Applause} = [scriptblock]::Create($using:applauseFunction)
    Get-Applause
} 

#endregion