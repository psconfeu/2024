using namespace System.Management.Automation

<#
.SYNOPSIS
Creates a new ErrorRecord object.

.DESCRIPTION
The New-ErrorRecord function creates a new ErrorRecord object with the specified error message, category, exception, error ID, target object, recommended action, and inner exception.

.PARAMETER Message
The error message.

.PARAMETER Category
The error category. Default value is 'NotSpecified'.


.PARAMETER Exception
The exception type.

.PARAMETER ErrorID
The error ID. Default value is 'NotSpecified'.

.PARAMETER TargetObject
The target object.

.PARAMETER RecommendedAction
The recommended action string.

.PARAMETER InnerException
The inner exception.

.EXAMPLE
New-ErrorRecord -Message "An error occurred" -Exception "System.Exception" -ErrorID "12345" -RecommendedAction "Please try again" -InnerException $ex

Creates a new ErrorRecord object with the specified parameters.

#>

Function New-ErrorRecord {
    [CmdletBinding(DefaultParameterSetName = 'default',
        SupportsShouldProcess = $false,
        ConfirmImpact = 'low')]
    Param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'default')]
        [String]
        $Message,

        [Parameter(ParameterSetName = 'default',
            Mandatory = $false)]
        [Management.Automation.ErrorCategory]
        $Category = 'NotSpecified',

        [Parameter(ParameterSetName = 'default',
            Mandatory = $true)]
        [string]
        $Exception ,

        [Parameter(ParameterSetName = 'default')]
        [string]
        $ErrorID = "NotSpecified",

        [Parameter(ParameterSetName = 'default',
            Mandatory = $false)]
        [System.Object]
        $TargetObject = $null,

        [Parameter(ParameterSetName = 'default')]
        [string]
        $RecommendedAction,

        [Parameter(ParameterSetName = 'default',
            Mandatory = $false)]
        [System.Exception]
        $InnerException

    )

    begin {}
    process {
        # Create a new ErrorRecord object
        # Add the inner exception to the ErrorRecord object if provided
        if ($InnerException) {
            $exceptionObject = New-Object -TypeName $Exception -ArgumentList $message, $InnerException
        }else {
            $exceptionObject = New-Object -TypeName $Exception -ArgumentList $message
        }
        $errorrecord = [System.Management.Automation.ErrorRecord]::new($exceptionObject, $errorID, $Category, $TargetObject)
        if ($recommendedAction) {
            $errorDetails = [System.Management.Automation.ErrorDetails]::new($errorrecord.Exception.Message)
            $errorDetails.RecommendedAction = $recommendedAction
            $errorrecord.ErrorDetails = $errorDetails
        }
        Return $errorrecord
    }
    end {}
}
Register-ArgumentCompleter -CommandName New-ErrorRecord -ParameterName Exception -ScriptBlock {
    param($commandName, $parameterName, $stringMatch)
    $stringMatch = $stringMatch.trim("'") # remove ' from search string if there was an space in the word
    ([appdomain]::CurrentDomain.GetAssemblies() | ForEach-Object {
        Try {
            $_.GetExportedTypes() | Where-Object {
                $_.Fullname -like '*Exception'
            }
        }
        Catch {}
    } ) | Where-Object Fullname -Like *$stringMatch* | Sort-Object -Property fullname | Select-Object -ExpandProperty fullname

}

