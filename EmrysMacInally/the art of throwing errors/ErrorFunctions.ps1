function Invoke-WriteError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [String[]]$InputObject
    )

    begin {}

    process {
        foreach ($item in $InputObject) {
            if ($item -eq "forbiddenFruit") {
                # https://powershellexplained.com/2017-04-07-all-dotnet-exception-list/
                
                #Write-Error -Message "$item is a invalid argument" -Category InvalidArgument -ErrorId "myerrorID" -TargetObject $item -RecommendedAction "Try a different fruit" -Exception ([System.ArgumentException]::New("dont use error"))
                #continue
            }
            Write-Output $item
        }
    }

    end {}
}

function Invoke-CmdletWriteError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [String[]]$InputObject
    )

    begin {}

    process {
        foreach ($item in $InputObject) {
            if ($item -eq "forbiddenfruit") {
                # https://powershellexplained.com/2017-04-07-all-dotnet-exception-list/
                $err = [System.Management.Automation.ErrorRecord]::new(
                    [System.ArgumentException]::New('wrong fruit'),
                    'FruityErrorID',
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $item
                )
                
                $PSCmdlet.WriteError($err)
                continue
            }
            Write-Output $item
        }
    }

    end {}
}


function Invoke-ThrowSimple {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [String[]]$InputObject
    )

    begin {}

    process {
        foreach ($item in $InputObject) {
            if ($item -eq "forbiddenfruit") {
                Throw 'File not found'
            }
            Write-Output $item
        }
    }

    end {}
}

function Invoke-ThrowException {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [String[]]$InputObject
    )

    begin {}

    process {
        foreach ($item in $InputObject) {
            if ($item -eq "forbiddenfruit") {
                Throw [System.ArgumentException]::new("passed in wrong string")
            }
            Write-Output $item
        }
    }

    end {}
}

function Invoke-ThrowErrorRecord {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [String[]]$InputObject
    )

    begin {}

    process {
        foreach ($item in $InputObject) {
            if ($item -eq "forbiddenfruit") {

                $err = [System.Management.Automation.ErrorRecord]::new(
                    [System.ArgumentException]::new("passed in wrong string"),
                    "MyErrorID",
                    [System.Management.Automation.ErrorCategory]::InvalidArgument,
                    $item
                )

                $err.CategoryInfo.Activity = 'Invoke-ThrowErrorRecord'

                $errDetails = [System.Management.Automation.ErrorDetails]::new("Parameter value is invalid.")
                $errDetails.RecommendedAction = "don't pass in error"
                $err.ErrorDetails = $errDetails
                Throw $err
            }
            Write-Output $item
        }
    }

    end {}
}



function Invoke-ThrowTerminatingError {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true)]
        [String[]]$InputObject
    )

    begin {}

    process {
        foreach ($item in $InputObject) {
            if ($item -eq "forbiddenfruit") {
                $err = New-ErrorRecord -Message 'forbidden fruit' -Category InvalidArgument -ErrorID 'FruityError' -TargetObject $item -Exception System.ArgumentException -RecommendedAction 'bla bla bla'
                $PSCmdlet.ThrowTerminatingError($err)
            }
            Write-Output $item
        }
    }

    end {}
}



function Invoke-Rethrow {
    [CmdletBinding()]
    param ()   

    begin {}

    process {
        try {
            Import-Excel -Path 'c:\IDontExist.xlsx'
        }
        catch {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    end {}
}

function Invoke-InnerException {
    [CmdletBinding()]
    param ()

    begin {}

    process {
        try {
            Import-Excel -Path 'c:\IDontExist.xlsx'
        }
        catch {
            $err = [System.Management.Automation.ErrorRecord]::New(
                [System.IO.FileNotFoundException]::New("New Message: $($_.Exception.Message)", $_.Exception),
                "myerrorID",
                [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                $null)
            $PSCmdlet.ThrowTerminatingError($err)
        }
    }

    end {}
}
