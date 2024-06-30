
break
# DEMO 2 - 1 - Then came Emanuel and AzAuth!
# https://github.com/PalmEmanuel/AzAuth
Find-Module AzAuth

$TokenSplat = @{
    Resource    = '499b84ac-1321-427f-aa17-267ca6975798' 
    Scope       = '.default'
    Interactive = $true
    TenantId    = $tenantID
}
$Token = (Get-AzToken @TokenSplat).Token

Invoke-RestMethod -Uri 'https://dev.azure.com/OrgName/_apis/projects/PSConf2024?api-version=7.2-preview.4' `
                  -Method Get `
                  -Headers @{
                    'Authorization' = "Bearer $Token"
                  }






break
# DEMO 2 - 2 - And we updated the ADOPS module
Remove-Module ADOPS -ErrorAction SilentlyContinue
Import-Module ADOPS

Connect-ADOPS -Organization 'OrgName' -TenantId $tenantID
Get-ADOPSProject -Project PSConf2024
