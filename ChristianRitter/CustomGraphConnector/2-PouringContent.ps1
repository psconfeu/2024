#Region Import the external data

$SessionsURI = "https://sessionize.com/api/v2/j7w9zn0t/view/sessions"
$Sessions = (Invoke-RestMethod -Method Get -Uri $SessionsURI).Sessions

#EndRegion

#Region transform the sessions into external items-layout

$ConnectionItemList = foreach($Session in $Sessions){
	@{
		id = $Session.Id
		properties = @{
			title = $Session.title
			description = $Session.questionAnswers.answer -join ', '
			speakers = ($Session.speakers).name -join ', '
			startsAt = ($Session.startsAt).tostring()
			Room = $Session.room
		}
		content = @{
			value = $Session.description
			type = 'text'
		}
		acl = @(
			@{
				accessType = "grant"
				type = "everyone"
				value = "everyone"
			}
		)
		activities = @(@{
			"@odata.type" = "#microsoft.graph.externalConnectors.externalActivity"
			type = "created"
			startDateTime = (Get-Date).AddDays(-1)
			performedBy = @{
				type = "user"
				id = $UserID 
			}
		})

	}
}

#EndRegion

#Region Ingest the external items into the connector

$ConnectionItemList.Foreach({
    Set-MgExternalConnectionItem -ExternalConnectionId $PreparedConnectionID -ExternalItemId $_.Id -BodyParameter $_ -ErrorAction Stop
})

#EndRegion