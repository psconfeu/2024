break
# DEMO 1 - 1 

# A full API that supports the Options method. List your stuff.
irm https://dev.azure.com/OrgName/_apis -Method Options | % value | ogv




# And a good set of API docs
Start-Process 'https://learn.microsoft.com/en-us/rest/api/azure/devops/?view=azure-devops-rest-7.2'




# Where examples aren’t good, there are blog posts
start-process https://github.com/bjompen/Set-AzDoRepoPermission/blob/main/Set-AzDoRepoPermission/Set-AzDoRepoPermission.ps1






break
# In the beginning there was a PAT

$B64Pat = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("`:$PAT"))

Invoke-RestMethod -Uri 'https://dev.azure.com/OrgName/_apis/projects/PSConf2024?api-version=7.2-preview.4' `
                  -Method Get `
                  -Headers @{
                    Authorization = "Basic $B64Pat"
                  }






break
# DEMO 1 - 2 - That we wrapped in a module
Remove-Module ADOPS -ErrorAction SilentlyContinue
Import-Module ADOPS -MaximumVersion 1.2.0

Connect-ADOPS -Username 'my@emailaddress.com' `
              -PersonalAccessToken $PAT `
              -Organization 'OrgName'

Get-ADOPSProject -Project PSConf2024
