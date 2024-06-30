break
# DEMO 3 - Log in using a managed identity

# Supported since a while back
Start-Process 'https://learn.microsoft.com/azure/devops/integrate/get-started/authentication/service-principal-managed-identity?view=azure-devops'


# So what is a managed identity? An identity owned by a resource...


# That we can import as a user in Azure DevOps and grant access to.
Start-Process 'https://dev.azure.com/OrgName/_settings/users'






# And the ADOPS module automagically supports it!
Remove-Module ADOPS -ErrorAction SilentlyContinue
Import-Module ADOPS

Connect-ADOPS -ManagedIdentity -SkipVerification -Organization 'OrgName' -TenantId $tenantID
Get-ADOPSProject -Project PSConf2024




# VMSS and self hosted still needs service connections though..
Start-Process 'https://dev.azure.com/OrgName/AzDMAuto/_settings/adminservices?resourceId=3ffc2fbe-6fc9-474a-81ad-7d006e1d7fec'
