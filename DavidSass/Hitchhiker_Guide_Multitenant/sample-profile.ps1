<#
    Sample profile script matching the PSConfEU presentation "The Hitchhiker's Guide to Multitenant Environments"

    The `set-profile` function requires that you create dedicated Windows Terminal profiles for each tenant, with the tenant ID as the profile name in curly braces.

    This sample sets some default paramaters to make sure Azure PowerShell session information is NOT shared between processes, and that the connection is always made using device code flow.
#>

$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

function set-profile {
    param (
        #Tenant ID as a string with curly braces
        [string]$tenantId
    )
    # Set defaults for Az PowerShell module on Environment scope
    Update-AzConfig -Scope Process -DisplaySurveyMessage $false -DisplayBreakingChangeWarning $false 3>&1| Out-Null

    $PSDefaultParameterValues["Connect-AzAccount:UseDeviceAuthentication"] = $true
    $PSDefaultParameterValues["Connect-AzAccount:Scope"] = "Process"
    $PSDefaultParameterValues["Connect-AzAccount:Tenant"] = $tenantId.trim('{}')


    $PSDefaultParameterValues["Connect-MgGraph:UseDeviceCode"] = $true
    $PSDefaultParameterValues["Connect-MgGraph:TenantId"] = $tenantId.trim('{}')
    $PSDefaultParameterValues["Connect-MgGraph:Scopes"] = @("Group.Read.All", "Application.Read.All", "User.ReadBasic.All")


    $env:AZURE_CONFIG_DIR = Join-Path $([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)) ".azure/$tenantId"

    # Super important to set the variable AFTER oh-my-posh has been initialized
    (@(&"oh-my-posh" init powershell --config="$PSScriptRoot\cloud-native-azure-plus.omp.json" --print) -join "`n") | Invoke-Expression
    $env:POSH_AZURE_ENABLED = $true

}

# Check that the WT_PROFILE_ID environment variable is set meaning that Windows Terminal is being used
if ($env:WT_PROFILE_ID) {
    set-profile -tenantId $env:WT_PROFILE_ID
    function az-login { az.cmd login --tenant $($env:WT_PROFILE_ID.trim('{}')) --use-device-code }
} else {
    function az-login { az.cmd login --use-device-code }
}