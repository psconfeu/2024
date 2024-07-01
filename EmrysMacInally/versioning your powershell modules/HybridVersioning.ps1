# Get version from manifest
$currentVersion = [version](Import-PowerShellDataFile -Path .\ErrorRecord\ErrorRecord.psd1).moduleVersion
Write-Host ("Current version: {0}.{1}" -f $currentVersion.major, $currentVersion.minor)

# Get git revision count
$patch = git rev-list --count HEAD

# Create new version
$newVersion = [version]::new($currentVersion.Major, $currentVersion.Minor, $patch)
Update-ModuleManifest -ModuleVersion $newVersion -Path .\ErrorRecord\ErrorRecord.psd1

# Get version from manifest
$version = (Import-PowerShellDataFile -Path .\ErrorRecord\ErrorRecord.psd1).ModuleVersion
Write-Host "New version: $version"

Publish-Module -Path .\ErrorRecord -Repository psinternal  -NuGetApiKey $env:localNugetApiKey
  