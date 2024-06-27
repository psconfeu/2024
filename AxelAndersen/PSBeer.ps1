#region Get secrets and connect ot Azure OpenAI
$secrets = Get-Secret AzOAISecrets -Vault AxKeys -AsPlainText | ConvertFrom-Json -AsHashtable
Set-AzOAISecrets @secrets
Set-OaIProvider AzureOpenAI
#endregion

#region Get a list of 20 belgian beers from Azure OpenAI
$invokeOAIChatParams = @{
    UserInput = "give me a list of 20 belgian beers, their alcohol percentage, name, description and IBU score in a json list"
    Instructions = "You are a beer connaisseur that specializes in belgian beer"
}

Invoke-OAIChat @invokeOAIChatParams | 
    Tee-Object -var beerlist | 
    ForEach-Object {($_ -split '```')[1] -replace 'json'} |  
    ConvertFrom-Json | 
    Set-Variable PSBeer
    $PSBeer
#endregion

#region In case of emergency, import the list of beers
$PSBeer = Import-Clixmlc:\dev\20beers.clixml
#endregion

#region Export the list of beers to different formats
$20000Beers = 1..1000 | ForEach-Object {$PSBeer}

$Path = 'C:\dev\20000Beers\'
New-Item -ItemType Directory -Path $Path

$20000Beers | Export-Parquet $Path\Beers.parquet
$20000Beers | Export-Excel $Path\Beers.xlsx
$20000Beers | Export-Csv $Path\Beers.csv

#endregion

#region compare sizes and get the data from parquet
Get-ChildItem $Path | Sort-Object Length | Tee-Object -Variable Sorted
$parquetVsCsv = "{0} is {1:N2} percent the size of {2}" -f $Sorted[0].Extension, ($Sorted[0].Length/$Sorted[-1].Length * 100), $Sorted[2].Extension
$parquetVsXlsx = "{0:N2} is {1:N2} percent the size of {2}" -f $Sorted[1].Extension, ($Sorted[1].Length/$Sorted[-1].Length * 100), $Sorted[2].Extension
$parquetVsCsv,$parquetVsXlsx | Write-Host
#endregion

#region get the data back
Import-Parquet $Path\Beers.parquet
(Import-Parquet $Path\Beers.parquet) | Measure-Object
#endregion

#region cleanup
Remove-Item $Path -Recurse;cls
#endregion
