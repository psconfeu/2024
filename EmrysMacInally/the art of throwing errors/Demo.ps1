. $PSScriptRoot\ErrorFunctions.ps1

############################################################################################################

#region Demo

# Get-ChildItem c:\nonexistantfolder\bla.txt
# 1 / 0
# Import-Excel -Path x:\nonexistingfile.xlsx

# $ErrorView = 'NormalView' 
# $ErrorView = 'ConciseView' 

#endregion

############################################################################################################

#region Demo Write-Error

# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-error?view=powershell-7.4

# Write-Error "MyWriteError"
# "Myerror" | Write-Error

#endregion

############################################################################################################

#region Demo Write-Error in function

# invoke-WriteError -inputObject 'apple', "forbiddenFruit", 'orange'
# Write-Host "Script still running"

#endregion

############################################################################################################

#region Demo Write-Error pipeline

# 'apple', "forbiddenFruit", 'orange' | invoke-WriteError
# Write-Host "Script still running"

#endregion

############################################################################################################

#region Demo Write-Error catch try

# try {
#     invoke-WriteError -inputObject 'apple', "forbiddenFruit", 'orange' #-ErrorAction stop
#     Write-Host "Script still running"
# }
# catch {
#     Write-Host "ran into an error"
#     $PSItem
# }

#endregion

############################################################################################################

#region Demo Write-Error control with $erroractionpreference

# $erroractionpreference = 'continue'
# invoke-WriteError -inputObject 'apple', "forbiddenFruit", 'orange'
# Write-Host "Script still running"

#endregion

############################################################################################################

#region Demo Write-Error $?

# invoke-WriteError -inputObject "forbiddenFruit" #-ErrorAction stop
# $?

#endregion

############################################################################################################

#region Demo PsCmdlet.WriteError / try catch 

# try {
#     Invoke-CmdletWriteError -inputObject 'apple', "forbiddenFruit", 'orange' #-ErrorAction stop
#     Write-Output "Script still running"
# }
# catch {
#     Write-Output "caught error"
#     $_
# }

#endregion

############################################################################################################

#region Demo PsCmdlet.WriteError  / $?

# Invoke-CmdletWriteError -inputObject "forbiddenFruit"
# $?

#endregion

############################################################################################################
#region Demo throw terminating error simple

# Invoke-ThrowSimple -inputObject 'apple', "forbiddenFruit", 'orange'
# Write-Host "Script still running"

#endregion

############################################################################################################

#region Demo throw $erroractionpreference and try catch behavior

# Invoke-ThrowSimple -inputObject 'apple', "forbiddenFruit", 'orange' #-ErrorAction SilentlyContinue
# Write-Host "Script still running"


# try {
#     Invoke-ThrowSimple -inputObject 'apple', "forbiddenFruit", 'orange' #-ErrorAction SilentlyContinue
#     Write-Host "Script still running"
# }
# catch {
#     Write-Host "caught error"
#     $_
# }

#endregion

############################################################################################################

#region Demo throw exception

# Invoke-ThrowException -inputObject 'apple', "forbiddenFruit", 'orange'

#endregion

############################################################################################################

#region Demo throw error record

# Invoke-ThrowErrorRecord -inputObject 'apple', "forbiddenFruit", 'orange'

#endregion

############################################################################################################

#region Demo PsCmdlet.ThrowTerminatingError / try catch

# Invoke-ThrowTerminatingError -inputObject 'apple', "forbiddenFruit", 'orange' #-ErrorAction SilentlyContinue
# Write-Output "Script still running"

# try {
#     Invoke-ThrowTerminatingError -inputObject 'apple', "forbiddenFruit", 'orange' 
#     Write-Output "Script still running"
# }
# catch {
#     Write-Output "caught error"
#     $_
# }

#endregion





############################################################################################################
############################################################################################################
############################################################################################################
# Bonus
############################################################################################################
############################################################################################################
#region rethrow error

# Invoke-Rethrow

#endregion

############################################################################################################

#region InnerException 

# Invoke-InnerException

#endregion
############################################################################################################

#region Demo catching specific exception

# try {
#     Invoke-ThrowTerminatingError -inputObject 'apple', "forbiddenFruit", 'orange' #-ErrorAction stop
#     Write-Output "Script still running"
# }catch [System.ArgumentException] {
#     Write-Output "caught ArgumentException error"
#     $_
# }catch [System.IO.FileNotFoundException] {
#     Write-Output "caught FileNotFoundException error"
#     $_
# }catch  {
#     Write-Output "caught other error"
#     $_
# }

#endregion

############################################################################################################

