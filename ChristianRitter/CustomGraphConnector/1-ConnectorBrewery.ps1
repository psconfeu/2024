#Region Step 1: Create AppRegistration

# Establish Connection to the target Tenant
Connect-MgGraph -Scopes AppRoleAssignment.ReadWrite.All,Application.ReadWrite.All, User.Read.All

# PreConfigurations
$TenantID = $(Get-MgContext).TenantId
#UserID of the user "who" posted the data
$UserID = (Get-mguser -UserId (get-mgcontext).Account).ID

$DisplayName = "PSConfEU2024 - Connector"

$Roles =  @{
	"ExternalConnection.ReadWrite.OwnedBy" = "f431331c-49a6-499f-be1c-62af19c34a9d"
	"ExternalItem.ReadWrite.OwnedBy" = "8116ae0f-55c2-452d-9944-d18420f5b2c8"
}

$AppIDs = @{
	"Microsoft.Graph" = "00000003-0000-0000-c000-000000000000"
}


# Define a required Resource Access Object

$RequiredResourceAccessObject = (@{
	"resourceAccess" = (
		@{
			id = $Roles["ExternalConnection.ReadWrite.OwnedBy"]
			type = "Role"
		},
		@{
			id = $Roles["ExternalItem.ReadWrite.OwnedBy"]
			type = "Role"
		}
	)
	"resourceAppId" = $AppIDs["Microsoft.Graph"]
})

# New AppRegistration
$newMgApplicationSplat = @{
    DisplayName = $DisplayName
    RequiredResourceAccess = $requiredResourceAccessObject
}

$AppRegistration = New-MgApplication @newMgApplicationSplat

# New ServicePrincipal
$ServicePrincipalMicrosoftGraphID = $(Get-MgServicePrincipal -Filter "appId eq '$($AppIDs["Microsoft.Graph"])'").Id
$ServicePrincipalAppRegistration = New-MgServicePrincipal -AppId $AppRegistration.appId

# New Admin Consent via AppRoleAssignments for the defined Roles
$Roles.Values.ForEach({

	$newMgServicePrincipalAppRoleAssignmentSplat = @{
		ServicePrincipalId = $ServicePrincipalAppRegistration.Id
		PrincipalId = $ServicePrincipalAppRegistration.Id
		AppRoleId = $_
		ResourceId = $ServicePrincipalMicrosoftGraphID
	}
	New-MgServicePrincipalAppRoleAssignment @newMgServicePrincipalAppRoleAssignmentSplat

})

# New Client Secret - Valid 6 Months
$passwordCredential = @{
	displayName = "$DisplayName - Secret"
	endDateTime = (Get-Date).AddMonths(6)
 }
$ClientSecret = Add-MgApplicationPassword -ApplicationId $AppRegistration.ID -PasswordCredential $passwordCredential

Disconnect-MgGraph
#EndRegion

#Region Step 2: (re)Connect via the AppRegistration

[pscredential]$ClientSecretCredential = New-Object System.Management.Automation.PSCredential ($AppRegistration.AppId, $(ConvertTo-SecureString ($ClientSecret.SecretText) -AsPlainText -Force))
Connect-MgGraph -ClientSecretCredential $ClientSecretCredential -TenantId $TenantID 

#EndRegion

#Region Step 3: Create New AdaptiveCardObject

# Initialize to an empty hashtable to explicitly define the type as hashtable.

# This is needed to avoid the breaking change introduced in PowerShell 7.3 - https://github.com/PowerShell/PowerShell/issues/18524.
# https://github.com/microsoftgraph/msgraph-sdk-powershell/issues/2352

[hashtable]$adaptiveCard = @{}
$adaptiveCard += Get-Content -Path ".\Layout.json" -Raw | ConvertFrom-Json -AsHashtable

#EndRegion

#Region Step 4: Design the Schema for Search Items
$Schema  = @(
    @{
        name          = "title"
        type          = "String"
        isQueryable   = $true
        isSearchable  = $true
        isRetrievable = $true
        labels        = @(
            "title"
        )
    }
    @{
        name          = "speakers"
        type          = "String"
        isQueryable   = $true
        isSearchable  = $true
        isRetrievable = $true
    }
    @{
        name          = "room"
        type          = "String"
        isQueryable   = $true
        isSearchable  = $true
        isRetrievable = $true
    }
    @{
        name          = "startsAt"
        type          = "String"
        isQueryable   = $true
        isSearchable  = $true
        isRetrievable = $true

    }
    @{
        name          = "description"
        type          = "String"
		isQueryable   = $true
        isSearchable  = $true
        isRetrievable = $true
    }


)
#EndRegion

#Region Step 5: Design the JSON for the Connector
$baseExternalUrl = "https://sessionize.com/api/v2/j7w9zn0t/view/Session/"
$searchResultTemplatesID = "psconfeu"
$ConnectionID = "pscconfeu"
$ConnectionName = "psconfeu 2024"
$ConnectionDescription = "PowerShell Conference Europe 2024"

$externalConnection = @{
	userId     = $UserID # From Azure Entra ID
	# The name of the connection, as it will appear in the Microsoft Search admin center
	# Defines the details of the connection
	connection = @{
		id               = $ConnectionID
		name             = $ConnectionName
		description      = $ConnectionDescription
		activitySettings = @{
			urlToItemResolvers = @(
				@{
					"@odata.type" = "#microsoft.graph.externalConnectors.itemIdResolver"
					urlMatchInfo  = @{
						baseUrls   = @(
							"$($baseExternalUrl)"
						)
						urlPattern = "/(?<slug>[^/]+)"
					}
					itemId        = "{slug}"
					priority      = 1
				}
			)
		}
		searchSettings   = @{
			searchResultTemplates = @(
				@{
					id       = $searchResultTemplatesID
					priority = 1
					layout   = @{
                        additionalProperties = $adaptiveCard
                    }
				}
			)
		}
	}
	# The schema is a way of defining the columns that will be available in the search results and how they are mapped to the content
	# https://learn.microsoft.com/graph/connecting-external-content-manage-schema
	schema  = $Schema
}
#EndRegion

#Region Step 6: Create the Connector

# Create the external connection
New-MgExternalConnection -BodyParameter $externalConnection.connection -ErrorAction Stop

#EndRegion

#Region Step 7: Update the Schema for the Connector

# Update the schema of the external connection
$body = @{
	baseType = "microsoft.graph.externalItem"
	properties = $externalConnection.schema
}
Update-MgExternalConnectionSchema -ExternalConnectionId $externalConnection.connection.id -BodyParameter $body -ErrorAction Stop

# wait for the schema to be applied
do {
	$connection = Get-MgExternalConnection -ExternalConnectionId $externalConnection.connection.id
	Start-Sleep -Seconds 60
	Write-Host "." -NoNewLine -ForegroundColor Yellow
} while ($connection.State -eq 'draft')

#EndRegion