#region add msal and set auth variables
Add-Type -Path ".\AUTH\AuthIsEasy\bin\Debug\net8.0\Microsoft.Identity.Client.dll"

$clientId = 'a8616097-26f4-4390-85e4-d0b047403688'
$tenantId = 'powers-hell.com'
[string[]]$scopes = @("https://graph.microsoft.com/.default")
#endregion

#region auth flow
$publicClientApp = [Microsoft.Identity.Client.PublicClientApplicationBuilder]::Create($clientId).
WithAuthority("https://login.microsoftonline.com/$tenantId").WithDefaultRedirectUri().Build()

$authenticationResult = $publicClientApp.AcquireTokenInteractive($scopes).ExecuteAsync().GetAwaiter().GetResult()
$authenticationResult
#endregion

#region create the header, make a basic graph request
$restParams = @{
    Uri         = "https://graph.microsoft.com/beta/me"
    Method      = 'GET'
    Headers     = @{ Authorization = $authenticationResult.CreateAuthorizationHeader() }
    ContentType = 'application/json'
}
$graphResponse = Invoke-RestMethod @restParams
$graphResponse
#endregion

#region How do I get the auth libraries?
# pick your dotnet version, install it, and run the following commands
dotnet new console -n "AuthIsEasy" --framework "net8.0"
Set-Location "$pwd\AuthIsEasy"
dotnet add package Microsoft.Identity.Client
# other libraries are helpful Microsoft.Identity.Client.Extensions.Msal, Microsoft.Identity.Client.Broker
dotnet build
#endregion