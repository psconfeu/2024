<#
Setup 
register-PSResourceRepository -name psinternal -Trusted -Uri http://localhost:8624/nuget/psinternal/ -ApiVersion v2
register-psrepository -name psinternal -SourceLocation http://localhost:8624/nuget/psinternal/ -InstallationPolicy Trusted -PublishLocation http://localhost:8624/nuget/psinternal/ 
http://localhost:8624/feeds/psinternal
#>


Set-Location .\DemoRepo


#region Update module version manually
code .\ErrorRecord\ErrorRecord.psd1

Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey
Find-module -Name ErrorRecord -Repository psinternal

# update module version and prerelease tag manually
Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey
Find-module -Name ErrorRecord -Repository psinternal 
# You need -allowPrerelease to see a prerelease
Find-module -Name ErrorRecord -Repository psinternal -allowPrerelease

#endregion

#region Update module version with script

Update-ModuleManifest -Path .\ErrorRecord\ErrorRecord.psd1  -ModuleVersion 0.2.0
Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey
Find-module -Name ErrorRecord -Repository psinternal -allowPrerelease -AllVersions
# Update module version and prerelease tag with script

Update-ModuleManifest -Path .\ErrorRecord\ErrorRecord.psd1  -ModuleVersion 0.2.1 -Prerelease "alpha01"
Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey
Find-module -Name ErrorRecord -Repository psinternal -allowPrerelease -AllVersions

Update-ModuleManifest -Path .\ErrorRecord\ErrorRecord.psd1  -ModuleVersion 0.2.1 -Prerelease "rc01"
Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey
Find-module -Name ErrorRecord -Repository psinternal -allowPrerelease -AllVersions

Update-ModuleManifest -Path .\ErrorRecord\ErrorRecord.psd1  -ModuleVersion 0.2.1 -Prerelease "preview01"
Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey

# Add -force to publish a lower version
Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey -force
Find-module -Name ErrorRecord -Repository psinternal -allowPrerelease -AllVersions

# PSResourceGet will allow lower version to be published
# publishing same version twice with PSResourceGet
Update-ModuleManifest -Path .\ErrorRecord\ErrorRecord.psd1  -ModuleVersion 0.1.5
Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey
Publish-PSResource -Path .\ErrorRecord\ -Repository psinternal  -ApiKey $env:localNugetApiKey
Find-module -Name ErrorRecord -Repository psinternal -allowPrerelease -AllVersions

# publishing same version twice
Update-ModuleManifest -Path .\ErrorRecord\ErrorRecord.psd1  -ModuleVersion 0.3.0
Publish-Module -Path .\ErrorRecord\  -Repository psinternal -NuGetApiKey $env:localNugetApiKey -force
Find-module -Name ErrorRecord -Repository psinternal -AllVersions

#region Incremental versioning
code ..\IncrementalVersioning.ps1
#endregion

#region Hybrid versioning
code ..\HybridVersioning.ps1
#endregion

#region GitVersion

# init git repo
git init
git add .
git commit -m "Initial commit"

# gitversion show all variables
gitversion

# only show nuget version
gitversion /showvariable nugetVersionV2

# committing without GiVersion.yml config
git commit --allow-empty -m "empty commit"
gitversion /showvariable nugetVersionV2

#show gitversion config
gitversion /showconfig

# create GitVersion.yml
Rename-Item .\_GitVersion.yml .\GitVersion.yml
code .\GitVersion.yml

# version with GitVersion.yml
gitversion /showvariable nugetVersionV2

#create a tag as starting point 
git tag 1.0.0
gitversion /showvariable nugetVersionV2

# commit on main branch
git commit --allow-empty -m "empty commit"
gitversion /showvariable nugetVersionV2
git commit --allow-empty -m "empty commit"
gitversion /showvariable nugetVersionV2

# create a patch branch
git switch -c patch/newPatch
gitversion /showvariable nugetVersionV2
git commit --allow-empty -m "empty commit"
gitversion /showvariable nugetVersionV2

# switch back to main branch check version and merge patch branch
git switch main
gitversion /showvariable nugetVersionV2
git merge patch/newPatch --no-ff
gitversion /showvariable nugetVersionV2

#create a feature branch
git switch -c feature/newFeature
gitversion /showvariable nugetVersionV2
git commit --allow-empty -m "empty commit"
gitversion /showvariable nugetVersionV2

# switch back to main branch check version and merge feature branch
git switch main
gitversion /showvariable nugetVersionV2
git merge feature/newFeature --no-ff
gitversion /showvariable nugetVersionV2

#create a feature branch
git switch -c feature/newFeature2
gitversion /showvariable nugetVersionV2
git commit --allow-empty -m "empty commit"
gitversion /showvariable nugetVersionV2

# update major version
git commit --allow-empty -m "my message +semver: major"
gitversion /showvariable nugetVersionV2

# switch back to main branch and merge feature branch
git switch main
gitversion /showvariable nugetVersionV2
git merge feature/newFeature2 --no-ff
gitversion /showvariable nugetVersionV2

#endregion