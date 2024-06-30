Push-Location C:\AzureDevOps\OrgName\ProjName\AzDM\Root
git checkout -b 'PSConfEURocks!'
mkdir PSConfEURocks
cd PSConfEURocks

'{}' | Out-File .\PSConfEURocks.json
'pipelines', 'repos', 'artifacts' | % {mkdir $_}

# repos
'{
    "repos.names": [
        "PSConfEU2024Rocks",
        "PSConfEU2025Rocks"
    ]
}' | Out-File .\repos\PSConfEURocks.repos.json

# pipelines
'{
    "pipelines.names": [
        "PSConfEU2024Rocks",
        "PSConfEU2025Rocks"
    ],
    "defaults": {
        "FolderPath": "/",
        "Name": "{{pipeline.name}}",
        "Repository": "{{pipeline.name}}",
        "YamlPath": ".\\azure-pipelines.yml"
    }
}' | Out-File .\pipelines\PSConfEURocks.pipelines.json

# artifacts
'{   
    "artifacts.names": [
        "PSConfEU2024Rocks",
        "PSConfEU2025Rocks"
    ]
}' | Out-File .\artifacts\PSConfEURocks.artifacts.json

cd ..

git add .
git commit -m 'PSConfEU Rocks!'
git push --set-upstream origin PSConfEURocks!

git checkout main
git branch -d PSConfEURocks!

Pop-Location

Start-Process 'https://dev.azure.com/OrgName/ProjName/_git/AzDM'