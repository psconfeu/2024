#region How to Setup a Runspace

# Basic Runspace
$Runspace  = [powershell]::Create()
$Runspace.AddScript({
    
    $Numbers = 1..100000 | ForEach-Object{ Get-Random -Minimum 1 -Maximum 997 }

    $MaxValue = $Numbers[0]
    foreach($num in $Numbers){  
        $MaxValue = [System.Math]::Max($MaxValue,$num)
    }
    return $MaxValue
})

$AsyncObject = $Runspace.BeginInvoke()

do{
    Start-Sleep -Milliseconds 100
}until($AsyncObject.IsCompleted)

$Result = $Runspace.EndInvoke($AsyncObject)
$Runspace.Dispose()



#EndRegion


#Region Setup a Runspace Factory (RunspacePool) and assign it to a Runspace

$RunspacePool = [runspacefactory]::CreateRunspacePool(1, 5)

$RunspacePool.Open()

$Runspace  = [powershell]::Create().AddScript({
    
    $Numbers = 1..100000 | ForEach-Object{ Get-Random -Minimum 1 -Maximum 997 }

    $MaxValue = $Numbers[0]
    foreach($num in $Numbers){  
        $MaxValue = [System.Math]::Max($MaxValue,$num)
    }
    return $MaxValue
})

$Runspace.RunspacePool = $RunspacePool
$AsyncObject = $Runspace.BeginInvoke()

do{
    Start-Sleep -Milliseconds 100
}until($AsyncObject.IsCompleted)


$Result = $Runspace.EndInvoke($AsyncObject)
$Runspace.Dispose()
$RunspacePool.Close()


#EndRegion


#region execute in parallel


$RunspacePool = [runspacefactory]::CreateRunspacePool(1, 5)

$RunspacePool.Open()
$jobs = 1..10 | Foreach-Object {

    $Runspace  = [powershell]::Create().AddScript({
    
        $Numbers = 1..1kb | ForEach-Object{ Get-Random -Minimum 1 -Maximum $(Get-Random -Minimum 1 -Maximum 1mb)  }
    
        $MaxValue = $Numbers[0]
        foreach($num in $Numbers){  
            $MaxValue = [System.Math]::Max($MaxValue,$num)
        }
        return $MaxValue
    })
    
    $Runspace.RunspacePool = $RunspacePool
    [PSCustomObject]@{
        State = $Runspace.BeginInvoke()
        Instance = $Runspace
    }
    
	
}

while ($Jobs.State.IsCompleted -contains $false) {Start-Sleep -Milliseconds 100}

$Results = $Jobs.ForEach({
    $Result = $_.Instance.EndInvoke($_.State)
    $_.Instance.Dispose()
    return $Result   
})

$RunspacePool.Close()

$Results

#endregion


