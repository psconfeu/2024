# The glue - Json

$Json = @'
{
    "value1": {
      "anArray": [
        "arrayValues"
      ]
    },
    "value2": {
        "object1": {},
        "object2": {},
        "object3": {}
    }
}
'@


$json | ConvertFrom-Json -AsHashtable

($json | ConvertFrom-Json -AsHashtable)['value2']



# OR - If you want it "live"
Start-Process 'https://dev.azure.com/OrgName/AzDMAuto/_git/AzDM?path=/Root/config.json'





# The glue - Git

git diff HEAD HEAD^ --name-only

# And again - Live..
Start-Process 'https://dev.azure.com/OrgName/AzDMAuto/_git/AzDM?path=/.pipelines/Push.yaml&version=GBmain&line=41&lineEnd=42&lineStartColumn=1&lineEndColumn=1&lineStyle=plain&_a=contents'


