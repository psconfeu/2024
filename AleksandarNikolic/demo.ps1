
Get-Module microsoft.graph.entra -ListAvailable

Find-Module Microsoft.Graph.Entra -AllowPrerelease
Start-Process 'https://www.powershellgallery.com/packages/Microsoft.Graph.Entra'

Install-Module Microsoft.Graph.Entra -AllowPrerelease -Force -Verbose

Install-Module Microsoft.Graph.Entra.Beta -AllowPrerelease -Force -Verbose

ii (Split-Path (gmo microsoft.graph.entra -ListAvailable).path[0])

Get-Command -Module Microsoft.Graph.Entra | Measure-Object # 214 commands in 0.10.0-preview
Get-Command -Module Microsoft.Graph.Entra.Beta | Measure-Object # 277 commands in 0.10.0-preview

Get-Command -Module Microsoft.Graph.Entra -Noun EntraUser* | Sort-Object Noun | Format-Table -GroupBy Noun

Get-Command Get-AzureAdUser -Syntax
Get-Command Get-MgUser -Syntax
Get-Command Get-EntraUser -Syntax

Connect-AzureAD
Connect-MgGraph
Connect-Entra

Get-AzureAdUser -Top 3
Get-MgUser -Top 3
Get-EntraUser -Top 3

Get-MgUser -Top 3 -Property UserType | Select UserType
Get-MgUser -Top 3 -Property DisplayName,Id,Mail,UserPrincipalName,UserType
Get-MgUser -Top 3 -Property DisplayName,Id,Mail,UserPrincipalName,UserType | Format-Table DisplayName,Id,Mail,UserPrincipalName,UserType

Get-EntraUser -Top 3 | Format-Table DisplayName,Id,Mail,UserPrincipalName,UserType

Get-AzureAdUser -ObjectId aleksandar@mydomain.onmicrosoft.com
Get-MgUser -UserId aleksandar@mydomain.onmicrosoft.com
Get-EntraUser -ObjectId aleksandar@mydomain.onmicrosoft.com

Get-EntraUser -ObjectId aleksandar@mydomain.onmicrosoft.com | Get-Member
Get-MgUser -UserId aleksandar@mydomain.onmicrosoft.com | Format-List *
Get-EntraUser -ObjectId aleksandar@mydomain.onmicrosoft.com | Format-List *

Get-MgUser -UserId 'aleksandar@mydomain.onmicrosoft.com' -Property displayName,userPrincipalName,signInActivity
$user = Get-MgUser -UserId 'cc666ee6-abf1-419c-c06e-g44abba945bd' -Property displayName,userPrincipalName,signInActivity
$user.SignInActivity
$user.SignInActivity | fl
$user.SignInActivity.AdditionalProperties

Get-EntraUser -ObjectId 'aleksandar@mydomain.onmicrosoft.com' | Select-Object displayName,userPrincipalName,signInActivity
Get-EntraUser -ObjectId 'aleksandar@mydomain.onmicrosoft.com' | Select-Object displayName,userPrincipalName -ExpandProperty signInActivity

# Pipeline
 
# this fails
Get-MgGroup -Filter "displayName eq 'TestGroup'" | Update-MgGroup -Description 'Test group'
# Update-MgGroup_UpdateViaIdentity$Expanded: The pipeline has been stopped.
# Exception: InputObject has null value for InputObject.GroupId
 
# this works
Get-MgGroup -Filter "displayName eq 'TestGroup'" | ForEach-Object { @{GroupId = $_.Id } } | Update-MgGroup -Description 'Test Group'

Get-EntraGroup -Filter "displayName eq 'TestGroup'" | Set-EntraGroup -Description 'New Test group'

Get-EntraGroup | Get-Member *id
Get-Help Set-EntraGroup -Full | code -

# How many parameters should accept a pipeline input?
Get-Help Get-EntraUser -Full | code -
Get-Help Get-EntraGroup -Full | code -

Get-AzureAdGroup -ObjectId 'b0c07cae-5f21-49db-a4b3-c42f53b98a8d' | Get-AzureAdGroupMember | Select-Object DisplayName,ObjectType
<#
DisplayName        ObjectType      
-----------        ----------
Aleksandar Nikolic User
Alex Wilber        User
testgroup1         Group
Diegos App3        ServicePrincipal
#>
# Where is a service principal?
Get-MgGroupMember -GroupId 'b0c07cae-5f21-49db-a4b3-c42f53b98a8d'
Get-MgGroupMember -GroupId 'b0c07cae-5f21-49db-a4b3-c42f53b98a8d'| fl
Get-EntraGroup -ObjectId 'b0c07cae-5f21-49db-a4b3-c42f53b98a8d' | Get-EntraGroupMember | Select-Object DisplayName,'@odata.type'


# Microsoft.Graph.PowerShell.Models.MicrosoftGraphDirectoryObject VS PSCustomObject
$userId = 'testni@mydomain.onmicrosoft.com'
Get-MgUserManager -UserId $userId
Get-EntraUserManager -ObjectId $userId
# TypeName: Microsoft.Graph.PowerShell.Models.MicrosoftGraphDirectoryObject
Get-MgUserManager -UserId $userId | gm
# TypeName: System.Management.Automation.PSCustomObject
Get-EntraUserManager -ObjectId $userId | gm
[Microsoft.Graph.PowerShell.Models.MicrosoftGraphUser](Get-MgUserManager -UserId $userId)
[Microsoft.Graph.PowerShell.Models.MicrosoftGraphUser](Get-MgUserManager -UserId $userId)| fl


# Assign a user's manager

# Navigation properties like manager cannot be used to update a user, and Update-MgUser will give you an error.

$AdeleM = Get-MgUser -UserId adelem@mydomain.onmicrosoft.com
$me = Get-MgUser -UserId aleksandar@mydomain.onmicrosoft.com

# The request body is a JSON object with an @odata.id parameter and the read URL for the user object to be assigned as a manager
$params = @{
	"@odata.id" = "https://graph.microsoft.com/v1.0/users/$($me.Id)"
}

Set-MgUserManagerByRef -UserId $AdeleM.Id -BodyParameter $params

Get-MgUserManager -UserId $AdeleM.Id -ov manager
$manager.ToJsonString() | ConvertFrom-Json

$Diego = Get-MgUser -UserId diegos@mydomain.onmicrosoft.com
Set-EntraUserManager -ObjectId $AdeleM.Id -RefObjectId $Diego.Id
Get-EntraUserManager -ObjectId $AdeleM.Id # PSCustomObject

(gcm Set-EntraUserManager).scriptblock | code -

Remove-EntraUserManager -ObjectId $AdeleM.Id -Debug

$user = Get-MgUser -UserId aleksandar@mydomain.onmicrosoft.com
$user | fl objectid, displayname, assignedplans

$user = Get-EntraUser -ObjectId aleksandar@mydomain.onmicrosoft.com
$user | fl objectid, displayname, assignedplans
$user | select objectid, displayname -expand assignedplans

(gcm Get-EntraUser).scriptblock | code -