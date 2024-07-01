$psdPath = ".\ErrorRecord\ErrorRecord.psd1"
[Version]$currentVersion = (Find-Module -Name ErrorRecord -Repository psinternal -ErrorAction SilentlyContinue).version
Write-Host "Current version: $currentVersion"
if ($currentVersion -lt [Version]::new(1, 0, 0)) {
    $newVersion = [Version]::new(1, 0, 0)
}
else {
    $newVersion = [Version]::new($currentVersion.Major, $currentVersion.Minor, $currentVersion.build + 1)
}
Update-ModuleManifest -Path $psdPath  -ModuleVersion $newVersion 
$version = (Import-PowerShellDataFile -Path $psdPath).ModuleVersion
Write-Host "New version: $version"

Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey

