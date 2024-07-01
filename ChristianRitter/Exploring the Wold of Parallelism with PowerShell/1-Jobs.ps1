#region Jobs 101
# create a job
$Job = Start-Job -ScriptBlock {
    $Numbers = 1..1000 | ForEach-Object{ Get-Random -Minimum 1 -Maximum 9999 }
    $MaxValue = $Numbers[0]
    foreach($num in $Numbers){
        $MaxValue = [System.Math]::Max($MaxValue,$num)
    }
    return $MaxValue
} -Name "MaxValueJob"  



# inspect our job

$job
$Job | Get-Member
$Job.ChildJobs | Get-Member
# receive the job
$Result = $Job | Wait-Job | Receive-Job
$Result

# cleanup
$Job | Remove-Job

# Deserialized Objects
$file =  Get-ChildItem -Path C:\Temp -file -ErrorAction SilentlyContinue
$file | Get-Member


$Outx = Start-Job -ScriptBlock {
    Get-ChildItem -Path C:\Temp -file -ErrorAction SilentlyContinue

} | Wait-Job | Receive-Job

$outx[0] | Get-Member

#endRegion

#region Streamlined Job
$Result = Start-Job -ScriptBlock {
    $Numbers = 1..1000 | ForEach-Object{ Get-Random -Minimum 1 -Maximum 9999 }

    foreach($num in $Numbers){
        $MaxValue = [System.Math]::Max($MaxValue,$num)
    }
    return $MaxValue
} |Receive-Job -AutoRemoveJob -Wait
#EndRegion

#region lets do some more jobs, in parallel/concurrent, investigate them🕵️‍♂️, and make them look fancy💅
function Start-MultiJob {
    <#
        .SYNOPSIS
        Start-MultiJob is a function that allows you to run multiple jobs concurrently and display their progress using a spinning cursor. It takes a list of script blocks as input and starts a job for each script block. The function continuously updates the job status and displays the progress on the console using a spinning cursor animation. The status for each line will be overwritten to provide real-time updates.

        .SYNTAX
        Start-MultiJob [-Jobs] <scriptblock[]> [[-SpinningCursor] <string[]>]

        .PARAMETER Jobs
        -Jobs <scriptblock[]>
        Specifies an array of script blocks representing the jobs to be executed concurrently.

        .PARAMETER SpinningCursor
        -SpinningCursor <string[]>
        Specifies an array of characters used for the spinning cursor animation. The default value is a set of characters: "|", "/", "-", and "\".

        .EXAMPLE
        PS> Start-MultiJob -Jobs $Jobs

        .OUTPUTS
        Returns the Output of each job with name as a PSCustomObject

        .NOTES

        The Start-MultiJob function relies on the Start-Job cmdlet to initiate jobs.
        The function continuously updates the job status and displays the progress until all jobs have completed.
        The progress of each job is shown using a spinning cursor animation.
        The status for each line will be overwritten to provide real-time updates.
        The job results are summarized at the end, indicating whether each job completed successfully or failed.
        The function temporarily hides the cursor during job execution and restores it afterwards.
    #>
    [CmdletBinding()]
    param (
        [scriptblock[]]$Jobs,
        [string[]]$SpinningCursor = @("|","/","-","\")
    )
    
    begin {
        function Clear-HostedLine {
            param (
                [int]$Line
            )
            
            $EmptyString = " " * [console]::WindowWidth
            $host.UI.RawUI.CursorPosition = @{ X = 0; Y = $Line }
            Write-Host "$EmptyString"
        }
        function Write-HostedLine {
            param (
                $JobItem,
                [switch]$Clear=$false,
                [switch]$Success =$false,
                [switch]$Failed =$false,
                [switch]$finished = $false
            )
            if($Clear){
                Clear-HostedLine -Line $JobItem.Line
            }
            $host.UI.RawUI.CursorPosition = @{ X = 0; Y = $JobItem.Line }
            if($Success){
                Write-Host "[+]$($JobItem.LastDisplayMessage)" -ForegroundColor Green
            }elseif ($Failed) {
                Write-Host "[-]$($JobItem.LastDisplayMessage)" -ForegroundColor Red
            }else {
                Write-Host "[$($SpinningCursor[$JobItem.CursorIconIndex])]$($JobItem.LastDisplayMessage)"
            }

        }
        $CursorPosition = $Host.UI.RawUI.CursorPosition.Y

        $JobList = $Jobs.ForEach({
            [PSCustomObject]@{
                Job = $Job = Start-Job -ScriptBlock $PSItem
                Set = $Job.ID
                Line = $CursorPosition
                LastDisplayMessage = $Null
                CursorIconIndex = 0
            }
            $CursorPosition++
        })
        
        [System.Console]::CursorVisible = $false
        
        
        Start-Sleep -Milliseconds 100
    }
    
    process {
        do {
            foreach($JobItem in $JobList | Where-Object{$PSItem.Job.State -eq "running"}){
                if($null -ne $JobItem.Job.ChildJobs.Information){
                    if($JobItem.LastDisplayMessage -ne $JobItem.Job.ChildJobs.Information[-1]){
                        $JobItem.LastDisplayMessage = $JobItem.Job.ChildJobs.Information[-1]
                        Clear-HostedLine -Line $JobItem.Line
                    }
                    Write-HostedLine -JobItem $JobItem
                    $JobItem.CursorIconIndex++
                    if ($JobItem.CursorIconIndex -eq $SpinningCursor.Count) {
                        $JobItem.CursorIconIndex = 0
                    }
                }
            }
            foreach($JobItem in $JobList | Where-Object{$PSItem.Job.State -ne "running"}){
                if($JobItem.LastDisplayMessage -ne $JobItem.Job.ChildJobs.Information[-1]){
                    $JobItem.LastDisplayMessage = $JobItem.Job.ChildJobs.Information[-1]
                    Clear-HostedLine -Line $JobItem.Line
                    Write-HostedLine -JobItem $JobItem
                }
            }
            Start-Sleep -Milliseconds 50
        } until ($JobList.Job.State -notcontains "running")
        
        # Make sure every information stream has been written
        
        foreach($JobItem in $JobList){
            $JobItem.LastDisplayMessage = $JobItem.Job.ChildJobs.Information[-1]
            if ($JobItem.Job.State -eq "completed") {
                Write-HostedLine -clear -Success -JobItem $JobItem
            } else {
                Write-HostedLine -clear -Failed -JobItem $JobItem
            }
        }
    }
    
    end {
        $host.UI.RawUI.CursorPosition = @{ X = 0; Y = $CursorPosition }
        [System.Console]::CursorVisible = $true
        foreach($JobItem in $JobList){
            [PSCustomObject]@{
                Task = $JobItem.Job.Name 
                RunDuration =  New-TimeSpan -Start $JobItem.Job.PSBeginTime -End $JobItem.Job.PSEndTime
                Output = $JobItem.Job.ChildJobs.Output
                Error = $JobItem.Job.ChildJobs.JobStateInfo.Reason.Message
            }
        }
    }
}

$Jobs = @(
    { write-host "Started Job 1"; Start-Sleep -Seconds 5; write-host "Doing Job 1"; Start-Sleep -Seconds 5; write-host "Job 1 Done"; return $(Get-Random -Maximum 10 -Minimum 1) },
    { write-host "Started Job 2"; Start-Sleep -Seconds 3; Write-Host "Doing Job 2"; Start-Sleep -Seconds 3; write-host "Job 2 Done"; return $(Get-Random -Maximum 10 -Minimum 1) },
    { write-host "Started Job 3"; Start-Sleep -Seconds 2; write-host "Doing Job 3"; Start-Sleep -Seconds 2; write-host "Job 3 Done"; Throw 'Emrys show me how to throw errors right, please!'; return $(Get-Random -Maximum 10 -Minimum 1) },
    { write-host "Started Job 4"; Start-Sleep -Seconds 4; write-host "Doing Job 4"; Start-Sleep -Seconds 4; write-host "Job 4 Done"; return $(Get-Random -Maximum 10 -Minimum 1) }
)


Start-MultiJob -Jobs $Jobs

$RollJob = Start-Job -ScriptBlock {
    Write-Host "Never gonna"
    Write-Warning "give you"
    return "up"
} -Name "RicksJob"  

$RollJob.ChildJobs.Information,
$RollJob.ChildJobs.Warning,
$RollJob.ChildJobs.Output -join " "

$RollJob.PSBeginTime
$RollJob.PSEndTime


get-command -parametername asjob
#endregion