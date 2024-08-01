<#
.SYNOPSIS
    Retrieves and organizes Microsoft Graph application permissions using provided functions.

.DESCRIPTION
    This script is designed to retrieve and structure Microsoft Graph application permissions. It leverages several 
    helper functions to send HTTP requests to the Microsoft Graph API, create structured data objects, and process 
    permissions. The script uses an access token for authorization and retrieves application roles, delegated permissions, 
    and resource-specific application permissions. It then iterates through all applications, matches the permissions, 
    and structures the data into PSCustomObjects.

.PARAMETER AccessToken
    Specifies the access token for authorization. This parameter is mandatory and should have the necessary permissions 
    to read service principal and application information from the Microsoft Graph API.

.EXAMPLE
    PS C:\> $AccessToken = "your-access-token"
    PS C:\> .\Get-MsGraphApplicationPermissions.ps1 -AccessToken $AccessToken

    This example runs the script to retrieve and organize all Microsoft Graph application permissions using the provided 
    access token.

.NOTES
    - The script requires a valid access token with appropriate permissions to read service principal and application 
      information from the Microsoft Graph API.
    - The script defines and uses the following functions:
        - Invoke-GraphWebRequest: Sends an HTTP request to a specified Microsoft Graph API endpoint.
        - Add-ToPSCustomObject: Creates a PSCustomObject with specified properties.
        - Get-AllGraphPermissions: Retrieves all permissions for the Microsoft Graph API.
        - Get-MsGraphApplicationPermissions: Retrieves and organizes Microsoft Graph application permissions.
    - Ensure the access token has the necessary permissions to access the required Microsoft Graph API resources.

    Author: Miriam Wiesner, @miriamxyra
#>

[cmdletbinding()]
param (
    [string]$AccessToken
)

<#
.SYNOPSIS
    Sends an HTTP request to the Microsoft Graph API.

.DESCRIPTION
    The Invoke-GraphWebRequest function sends an HTTP request to a specified Microsoft Graph API endpoint.
    It includes an authorization header with the provided access token and supports different HTTP methods 
    such as GET, POST, PUT, and DELETE. The function also handles JSON request bodies.

.PARAMETER AccessToken
    Specifies the access token for authorization. This parameter is mandatory.

.PARAMETER BodyAsJson
    Specifies the body of the request as a JSON object. This parameter is optional and is typically used 
    with HTTP methods that require a body, such as POST or PUT.

.PARAMETER RequestUri
    Specifies the URI of the Microsoft Graph API endpoint to which the request will be sent. This parameter 
    is mandatory.

.PARAMETER HttpMethod
    Specifies the HTTP method to be used for the request. The default value is "GET". Other common values 
    include "POST", "PUT", and "DELETE".

.EXAMPLE
    PS C:\> $AccessToken = "your-access-token"
    PS C:\> $RequestUri = "https://graph.microsoft.com/v1.0/me"
    PS C:\> Invoke-GraphWebRequest -AccessToken $AccessToken -RequestUri $RequestUri

    This example sends a GET request to the Microsoft Graph API to retrieve information about the authenticated user.

.EXAMPLE
    PS C:\> $AccessToken = "your-access-token"
    PS C:\> $RequestUri = "https://graph.microsoft.com/v1.0/users"
    PS C:\> $Body = [PSCustomObject]@{ displayName = "John Doe"; mailNickname = "johndoe"; userPrincipalName = "johndoe@example.com"; accountEnabled = $true; passwordProfile = @{ forceChangePasswordNextSignIn = $true; password = "xWwvJ]6NMw+bWH-d" }}
    PS C:\> Invoke-GraphWebRequest -AccessToken $AccessToken -RequestUri $RequestUri -HttpMethod "POST" -BodyAsJson $Body

    This example sends a POST request to the Microsoft Graph API to create a new user with the specified details.

.OUTPUTS
    The function returns the response from the Microsoft Graph API as a PSCustomObject.

.NOTES
    This function requires a valid access token with appropriate permissions for the requested resource.
    The function uses the Invoke-RestMethod cmdlet to send the HTTP request.
#>
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

<#
.SYNOPSIS
    Creates a PSCustomObject with specified properties.

.DESCRIPTION
    The Add-ToPSCustomObject function creates a PSCustomObject with the specified properties: Id, Value, Type,
    PermissionName, Description, AppId, and AppName. This function can be used to organize and structure 
    information into a custom object.

.PARAMETER Id
    Specifies the ID associated with the custom object. This parameter is mandatory.

.PARAMETER Value
    Specifies the value associated with the custom object. This parameter is mandatory.

.PARAMETER Type
    Specifies the type associated with the custom object. This parameter is mandatory.

.PARAMETER PermissionName
    Specifies the permission name associated with the custom object. This parameter is mandatory.

.PARAMETER Description
    Specifies the description associated with the custom object. This parameter is mandatory.

.PARAMETER AppId
    Specifies the application ID associated with the custom object. This parameter is mandatory.

.PARAMETER AppName
    Specifies the application name associated with the custom object. This parameter is mandatory.

.EXAMPLE
    PS C:\> $CustomObject = Add-ToPSCustomObject -Id "12345" -Value "SomeValue" -Type "String" -PermissionName "Read" -Description "Read permission for the app" -AppId "abcde-12345" -AppName "MyApp"

    This example creates a PSCustomObject with the specified properties and stores it in the $CustomObject variable.

.OUTPUTS
    The function returns a PSCustomObject with the specified properties.

.NOTES
    This function is a helper function and useful for creating structured data objects with specific properties.
#>
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

<#
.SYNOPSIS
    Retrieves all permissions for the Microsoft Graph API.

.DESCRIPTION
    The Get-AllGraphPermissions function retrieves all permissions for the Microsoft Graph API by sending an HTTP GET request
    to the Microsoft Graph API endpoint for service principals. The function uses an access token for authorization and 
    returns the response, which includes information about app roles, OAuth2 permission scopes, and resource-specific 
    application permissions.

.PARAMETER AccessToken
    Specifies the access token for authorization. This parameter is mandatory and should be passed as a global variable or 
    retrieved from a secure source before calling the function.

.EXAMPLE
    PS C:\> $AccessToken = "your-access-token"
    PS C:\> $Permissions = Get-AllGraphPermissions

    This example retrieves all permissions for the Microsoft Graph API and stores the response in the $Permissions variable.

.OUTPUTS
    The function returns a PSCustomObject containing the permissions and related information for the Microsoft Graph API.

.NOTES
    This function requires a valid access token with appropriate permissions to read service principal information from 
    the Microsoft Graph API. The function uses the Invoke-GraphWebRequest function to send the HTTP request.
#>
function Get-AllGraphPermissions {
    $RequestUri = "https://graph.microsoft.com/v1.0/servicePrincipals(appId='00000003-0000-0000-c000-000000000000')?$select=id,appId,displayName,appRoles,oauth2PermissionScopes,resourceSpecificApplicationPermissions"
    $HttpMethod = "GET"
    $Response = Invoke-GraphWebRequest -AccessToken $AccessToken -RequestUri $RequestUri -HttpMethod $HttpMethod
    return $Response
}

<#
.SYNOPSIS
    Retrieves and organizes Microsoft Graph application permissions.

.DESCRIPTION
    The Get-MsGraphApplicationPermissions function retrieves all application permissions for the Microsoft Graph API. 
    It fetches application roles, delegated permissions, and resource-specific application permissions. The function then 
    iterates through all applications and matches the permissions, creating a PSCustomObject for each permission found.

.PARAMETER AccessToken
    Specifies the access token for authorization. This parameter is mandatory and should have the necessary permissions 
    to read service principal and application information from the Microsoft Graph API.

.EXAMPLE
    PS C:\> $AccessToken = "your-access-token"
    PS C:\> $Permissions = Get-MsGraphApplicationPermissions -AccessToken $AccessToken

    This example retrieves and organizes all Microsoft Graph application permissions and stores the result in the 
    $Permissions variable.

.OUTPUTS
    The function returns an array of PSCustomObject, each containing details about a specific permission, including 
    its ID, value, type, name, description, associated application ID, and application name.

.NOTES
    This function requires a valid access token with appropriate permissions to read service principal and application 
    information from the Microsoft Graph API. The function relies on the Invoke-GraphWebRequest and Add-ToPSCustomObject 
    functions to send HTTP requests and structure the data.
#>
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
