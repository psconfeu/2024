[cmdletbinding()]
param (
    [string]$AccessToken
)

function Invoke-GraphWebRequest {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$AccessToken,
        [PSCustomObject]$BodyAsJson,
        [Parameter(Mandatory)]
        [string]$RequestUri,
        [string]$HttpMethod = "GET"
    )

    $Header = @{
        "Authorization" = "Bearer $AccessToken"
        "Content-Type"  = "application/json"
    }

    $Params = @{
        Headers = $Header
        uri     = $RequestUri
        Body    = $BodyAsJson
        method  = $HttpMethod
    }
    
    try
    {
        $Request = Invoke-RestMethod @Params -UserAgent "MSGraphSecurityTestKit"
    }
    catch {
        throw $_
    }
    return $Request
}

function Add-ToPSCustomObject {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Id,
        [Parameter(Mandatory)]
        [string]$Value,
        [Parameter(Mandatory)]
        [string]$Type,
        [Parameter(Mandatory)]
        [string]$PermissionName,
        [Parameter(Mandatory)]
        [string]$Description,
        [Parameter(Mandatory)]
        [string]$AppId,
        [Parameter(Mandatory)]
        [string]$AppName
    )

    [PSCustomObject]@{
        Id              = $Id
        Value           = $Value
        Type            = $Type
        PermissionName  = $PermissionName
        Description     = $Description
        AppId           = $AppId
        AppName         = $AppName
    }
}

function Get-AllGraphPermissions {
    $RequestUri = "https://graph.microsoft.com/v1.0/servicePrincipals(appId='00000003-0000-0000-c000-000000000000')?$select=id,appId,displayName,appRoles,oauth2PermissionScopes,resourceSpecificApplicationPermissions"
    $HttpMethod = "GET"
    $Response = Invoke-GraphWebRequest -AccessToken $AccessToken -RequestUri $RequestUri -HttpMethod $HttpMethod
    return $Response
}

function Get-MsGraphApplicationPermissions {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$AccessToken
    )

    $Response = Get-AllGraphPermissions
    $ApplicationPermissions = $Response.appRoles
    $DelegatedPermissions = $Response.oauth2PermissionScopes
    $ResourceSpecificPermissions = $Response.resourceSpecificApplicationPermissions

    $RequestUri = "https://graph.microsoft.com/v1.0/applications?$select=id"
    $HttpMethod = "GET"

    $Response = Invoke-GraphWebRequest -AccessToken $AccessToken -RequestUri $RequestUri -HttpMethod $HttpMethod

    $Permissions = $Response.value | ForEach-Object {
        $AppName = $_.displayName
        $AppId = $_.appId

        $_.requiredResourceAccess.resourceAccess | ForEach-Object {
            $Id = $_.id

            $ApplicationPermissions | ForEach-Object {
                if ($_.id -eq $Id) {
                    Add-ToPSCustomObject -Id $Id -Value $_.value -Type "Application" -PermissionName $_.displayName -Description $_.description -AppId $AppId -AppName $AppName
                }
            }
            $DelegatedPermissions | ForEach-Object {
                if ($_.id -eq $Id) {
                    Add-ToPSCustomObject -Id $Id -Value $_.value -Type "Delegated" -PermissionName $_.adminConsentDisplayName -Description $_.adminConsentDescription -AppId $AppId -AppName $AppName
                }
            }
            $ResourceSpecificPermissions | ForEach-Object {
                if ($_.id -eq $Id) {
                    Add-ToPSCustomObject -Id $Id -Value $_.value -Type "ResourceSpecific" -PermissionName $_.displayName -Description $_.description -AppId $AppId -AppName $AppName
                }
            }
        }
    }

    return $Permissions
}

Get-MsGraphApplicationPermissions -AccessToken $AccessToken
