# Boost your Azure Functions with API Management

This document will guide you through the Follow Along session about Azure API Management.

## Step 1 - Getting an environment

Run `.\Get-BoostAPIMEnvironment.ps1 -Name <YourName> -Email <YourEmail>`. It will ask you for your Name and Email address. This email address won't be used for anything but is needed for the API Management, you can enter any valid email address. For the name please provide a name only using the latin alphabet (a-z A-Z) or numbers (0-9). The name can be anything, this will be used to name your resources in Azure. Your environment and account will be deleted after this session. If you want to follow along in your own environment create the following:

- Resourcegroup
- Basic V2 API Management (besides SKU it's default settings)
- Consumption tier Function using PowerShell Core 7.4 running Window (rest is default settings, if you want you can rename the storage account and app insight workspace)
- Keyvault (default settings)

## Step 2 - Hello World

Create a **http trigger** function in the Function App and put the authentication level on **Anonymous**.
Replace the code of the function with the following code:

```Powershell

using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Get the name from the Query
$name = $Request.Query.Name ?? "World"

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = "Hello $name!"
})
```

Get the Function URL (master).

Test if the function works by calling it with and without a "name" query parameter.

Now go to your API Management Instance and create a HTTP Api. You can name it anything you want.
Go into the settings of the API and look for the setting **Subscription required** and disable this checkbox.
Create an operation called "hello".
Add the azure function URL as a back-end url.
Add an inbound policy type to rewrite the URL to remove `/hello` from the url.

## Step 3 - Frag it

Check the inbound policy and copy the inbound policies. This should look something like:

```Api Management Policy
<rewrite-uri template="/" />
<set-backend-service base-url="https://YOURFUNCTIONAPP.azurewebsites.net/api/HttpTrigger1" />
```

Now go to the policy fragments blade in API Management and create a new policy fragments with the content you just copied. Call the fragment "call-function".

Go back to the inbound policy for the operation created in Step 2 and remove the lines which where copied before and replace these with.

```Api Management Policy
<include-fragment fragment-id="call-function" />
```

Test to see if the API is still working.

## Step 4 - Hello allowed?

Go to the Keyvault and give yourself **Key Vault Secrets Officer** permissions and give the API Mangement managed identity **Key Vault Secrets User** permissions.

Create a secret with the name of someone or something which is allowed to get a hello (for example your own name). If you want you can create multiple values. As value enter a secret key you can remember (for example 12345).
Make sure you copy the url for the key-vault as this needs to be used later.

Create another policy-fragment called "check-keyvault" and use this code:

```Api Management Policy
<fragment>
    <send-request mode="new" response-variable-name="responseObj" timeout="30" ignore-error="true">
        <set-url>@($"https://YOURKEYVAULTNAME.vault.azure.net/secrets/{context.Request.Url.Query.GetValueOrDefault("Name","World")}?api-version=7.4")</set-url>
        <set-method>GET</set-method>
        <authentication-managed-identity resource="https://vault.azure.net" />
    </send-request>
    <choose>
        <when condition="@(!((IResponse)context.Variables["responseObj"]).Body.As<JObject>(preserveContent: true).ContainsKey("value"))">
            <return-response>
                <set-status code="401" reason="Unauthorized" />
            </return-response>
        </when>
        <when condition="@(!((string)((IResponse)context.Variables["responseObj"]).Body.As<JObject>(preserveContent: true)["value"]).Equals((string)context.Request.Headers.GetValueOrDefault("Key","")))">
            <return-response>
                <set-status code="401" reason="Unauthorized" />
            </return-response>
        </when>
    </choose>
</fragment>
```

Nested fragments aren't possible. If that would be possible the return response could be made into a separate fragment too.

Now create a new operation in the API Management (in the same API as before) called "hello-restricted". And add both fragments in the inbound policy like this:

```Api Management Policy
<include-fragment fragment-id="check-keyvault" />
<include-fragment fragment-id="call-function" />
```

Test the Api by using a query named "Name" where you use the name of the secret you made, and add a header named "Key" where you enter the value of the secret you made. Also see what happens when values are incorrect or missing.

## Step 5 - What's in the name

To make sure the policy fragments can be reused more easily go to named values in API management. Create two **plain** values named "FunctionName" (value is the name of the function) and "KeyVaultName" (value is the name of the keyvault).

Now replace the function and keyvault name in the policy fragment by using `{{Named Value Name}}` and test if the API's still work.

## Step 6 - Authorization

Create a new operation in API Management called "hello-auth". Set the inbound policy to this:

```Api Management Policy
<validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized" require-expiration-time="true" require-scheme="Bearer" require-signed-tokens="true">
    <openid-config url="https://login.microsoftonline.com/contoso.onmicrosoft.com/.well-known/openid-configuration" />
    <audiences>
        <audience>https://management.core.windows.net/</audience>
    </audiences>
    <issuers>
        <issuer>https://sts.windows.net/289178cb-1f7c-4171-b559-4885bd001c74/</issuer>
    </issuers>
</validate-jwt>
<include-fragment fragment-id="call-function" />
```

The issuers is set up to a Entra ID App registration in the demo environment. If you want to do this in your own environment you need to create an app registration (no redirect uri required) and create a client secret. Copy the client secret as this is needed later and copy the clientid from the app. This should replace the guid in the issuer uri.

To test it open powershell and log into azure using the following powershell script:

```PowerShell
$SecurePassword = Read-Host -Prompt 'Enter a Password' -AsSecureString
$TenantId = '289178cb-1f7c-4171-b559-4885bd001c74'
$ApplicationId = 'c32c9725-fb12-4e01-8ef3-cb7606b4c6d6'
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecurePassword
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
```

If you are doing this in your own environment replace the tenantID and the ApplicationId.
When prompted for the password enter the client secret which is provided by the speaker (or you copied it already when doing it in your own environment).

Now use the command `(Get-AzAccessToken).Token` to get your token.
Test the api by adding a Authorization header which consists of the word "bearer" followed by a space and then the full token. If succesfull the API should work while if the token isn't provided it should give a 401.

## Step 7 - Roles

If you are doing this in your own environment find the app registration you made before and create two app roles names "Admin" and "User", for the value and description you also use these values. Also you'll find the index.html file here. This needs to be hosted somewhere. You can for example host it in and Azure App service or use a tool like XAMPP to host it locally. The address of the place where you are hosting it should now be added as redirect uri for a Single Page App (SPA) in the app registration.

Create a new operation called "hello-role" and use the following code for the inbound policy:

```Api Management Policy
<validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized" require-expiration-time="true" require-scheme="Bearer" require-signed-tokens="true" output-token-variable-name="jwt">
    <openid-config url="https://login.microsoftonline.com/contoso.onmicrosoft.com/.well-known/openid-configuration" />
    <audiences>
        <audience>c32c9725-fb12-4e01-8ef3-cb7606b4c6d6</audience>
    </audiences>
    <issuers>
        <issuer>https://login.microsoftonline.com/289178cb-1f7c-4171-b559-4885bd001c74/v2.0</issuer>
    </issuers>
</validate-jwt>
<choose>
    <when condition="@(((Jwt)context.Variables["jwt"]).Claims.GetValueOrDefault("roles").Contains("Admin"))">
        <set-query-parameter name="Name" exists-action="override">
            <value>Admin</value>
        </set-query-parameter>
        <include-fragment fragment-id="call-function" />
    </when>
    <when condition="@(((Jwt)context.Variables["jwt"]).Claims.GetValueOrDefault("roles").Contains("User"))">
        <set-query-parameter name="Name" exists-action="override">
            <value>User</value>
        </set-query-parameter>
        <include-fragment fragment-id="call-function" />
    </when>
</choose>
```

Do not that the validate-jwt policy has changed as for this example a different OAuth version will be used. If you are doing this in your own environment make sure to set the application ID and tenant id correct.
If you are doing this in your own environment assign the Admin role from the app registration (enterprise app) to your user account.

Go to the webpage https://powerupapimlogin.azurewebsites.net/ in a private browsing window (or the window where you are logged into the azure portal). If you are doing this in your own environment go to the place where you hosted the index.html.

This page will prompt you with a loginscreen and login via a application in Entra ID. You can click the Login Link and it will show you the UPN you used, the roles you have assigned and the token. Wait untill the speaker has set all users to a specific role and log in (if you did so before make sure you log out first). Get the token and use this to call the API with a **Authorization** header starting with "bearer" followed by a space and then the token.

You should now see it say welcome and then the role you have.