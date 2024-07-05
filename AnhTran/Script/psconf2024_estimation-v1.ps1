<#
-------- CASE STUDIES - PSCONFEU 2024 --------------------------------------------------------
 Latest Update: 2024-05-27
 Language: PowerShell
 Data: Asset Maintenance, Fuel Records
-----------------------------------------------------------------------------------------------

-----------------------------------
 STEP 1: INSTALL RELEVANT PACKAGES
-----------------------------------
#>

# One Time installation:
#Install-Module -Name ImportExcel -Scope CurrentUser

Write-Output "Begin: $((Get-Date).ToString())"

try {
    Import-Module ImportExcel
}
catch {throw 
}

# Define Parameters
. ".\psconf2024-init.ps1"

<#
-----------------------------------
 STEP 2: REMOVE OLD RECORDS
-----------------------------------
#>

# Remove old records of last week:
# Reason: Sometimes needs to rectify human input errors

if (Test-Path -Path "..\Result\result.xlsx" -PathType Leaf) {
    Remove-Worksheet -WorksheetName $ws_delete_sheet -FullName $result

    $excelPackage = Open-ExcelPackage -Path $result

        foreach ($worksheet in $excelPackage.Workbook.Worksheets) {
            if ( $worksheet.Name -eq $ws_delete_rows) {
                # Define a variable to track the current row number
                $totalRows = $worksheet.Dimension.Rows

                do {
                    # Skip the header row (assuming it's the first row)
                    if ($totalRows -ne 1) {
                            $worksheet.DeleteRow($totalRows)
                    }

                    $totalRows--

                } while ($totalRows -gt 0)
                }
} Write-Output "KEEP CALM AND DRINK COFFEE"

    Close-ExcelPackage -ExcelPackage $excelPackage 
}


<#
-----------------------------------
 STEP 3: IMPORT RAW FILES
-----------------------------------
#>

# estimation:
## Convert the existing .csv to json format and write to disk
Import-Csv $estimation| ConvertTo-Json | Set-Content ..\Result\estimation.json

## Import json and write to estimation tab
Get-Content ..\Result\estimation.json | ConvertFrom-Json | Export-Excel -Path $result -WorksheetName "estimation"

# inventory:
Import-Excel -Path $inventory -WorksheetName "Sheet1"  |
Export-Excel -Path $result -WorksheetName "inventory" 

# operation:
Import-Excel -Path $operation -WorksheetName "Sheet1" -StartRow 7 |
Export-Excel -Path $result -WorksheetName "operation" 

# sales:
# Method 1:
Import-Csv -Path $sales |
Export-Excel -Path $result -WorksheetName "sales" 

# Method 2:
Import-Csv -Path $sales | ForEach-Object {
    [pscustomobject]@{
        'Date' = (Get-Date -Month $(-join $_.Date[3..4]) -Day $(-join $_.Date[0..1]) -Year $(-join $_.Date[6..9])).Date
        'Sales' = $_.Sales
        'Count_customers' = $_.Count_customers
        'Price' = $_.Price          
        'Weather' = $_.Weather        
        'Traffic' = $_.Traffic        
    }
} 

Import-Csv -Path $sales | Select-Object -ExcludeProperty Date -Property @{
    name = 'Date'
    expression = {(Get-Date -Month $(-join $_.Date[3..4]) -Day $(-join $_.Date[0..1]) -Year $(-join $_.Date[6..9])).Date}
}, Sales, Count_customers, Price, Weather, Traffic | Export-Excel -Path $result -WorksheetName "sales" 


# Last week utilization:
$Importvalues = @{
    Path = $last_week_utilization
    WorksheetName = "Sheet1"
    DataOnly = $true
    AsText = "Start time"
    StartRow = 1
    EndColumn = 7
    NoHeader = $false
    AsDate= "P4" 
}

Import-Excel @Importvalues |
Export-Excel -Path $result -WorksheetName "utilization" 

# This week utilization:
$Importvalues.Path=$this_week_utilization
$VerbosePreference = 'Continue'
Write-Verbose "Executing Import-Excel with the following parameters: $($Importvalues|Out-String)" -verbose
Write-Output "Opening $($Importvalues.Path) for processing with Import-Excel"

Import-Excel @Importvalues |
Export-Excel -Path $result -WorksheetName "utilization-new-hidden" 

<#-----------------------------------
 STEP 4: SHEET ESTIMATION
-----------------------------------
#>
$excelPackage = Open-ExcelPackage -Path $result

# Access the Estimation worksheet
$worksheet = $excelPackage.Workbook.Worksheets["estimation"]

# Add the formula to cell E2 through to E5
2..5 | ForEach-Object {
    $worksheet.Cells["E$_"].Formula = "B$_*(1-C$_-D$_)"
}

# Add the sum to E6
$worksheet.Cells["E6"].Formula = "SUM(E2:E5)*3.99"

# Let's add some color
$color = [System.Drawing.Color]::Yellow
Set-ExcelRange -Worksheet $worksheet -Range "E1" -BackgroundColor $color
Set-ExcelRange -Worksheet $worksheet -Range "E6" -BackgroundColor $color

Set-ExcelColumn -Worksheet $worksheet -Column 5 -Heading "Estimated Sales/Day" -AutoSize

# Auto size columns for the entire worksheet
$worksheet.Dimension.Columns | ForEach-Object {
    Set-ExcelColumn -Worksheet $worksheet -Column $_ -AutoFit 
}


<#
-----------------------------------
 STEP 5: SHEET OPERATION
-----------------------------------
#>

$worksheet = $excelPackage.Workbook.Worksheets["operation"]

Set-ExcelColumn -Worksheet $worksheet -Column 6 -Heading "Performed by" -AutoSize
Set-ExcelColumn -Worksheet $worksheet -Column 7 -Heading "WeekNum"
Set-ExcelColumn -Worksheet $worksheet -Column 8 -Heading "Year"

$rowcount = $worksheet.Dimension.Rows

2.. $rowcount | ForEach-Object {
    $worksheet.Cells["F$_"].Formula = "IF(B$_=`"PM`",`"Jimin`",`"Jennie`")"
    $worksheet.Cells["G$_"].Formula = "WEEKNUM(C$_,1)" # Week starts from Sun to Sat
    $worksheet.Cells["H$_"].Formula = "YEAR(C$_)"
}


<#
-----------------------------------
 STEP 6: SHEET utilization
------------------------------------
#>


# This Week utilization
$worksheet_this_week = $excelPackage.Workbook.Worksheets["utilization-new-hidden"]

$rowcount = $worksheet_this_week.Dimension.Rows

for ($i = $rowcount; $i -ge 2; $i--) {
    $cell_frequency = $worksheet_this_week.Cells[$i, 3]
    $cell_time = $worksheet_this_week.Cells[$i, 4]

    if (($cell_frequency.value -ne $frequency) -or ($null -eq $cell_time.value ) ) {      
        $worksheet_this_week.DeleteRow($i)
    }

}

#Last week utilization
$worksheet = $excelPackage.Workbook.Worksheets["utilization"]
$workSheet.InsertColumn(1,1)

Set-ExcelColumn -Worksheet $worksheet -Column 6 -Heading "Date_lastweek" -NumberFormat "Short Date"
Set-ExcelColumn -Worksheet $worksheet -Column 8 -Heading "Date_thisweek" -NumberFormat "Short Date" 
Set-ExcelColumn -Worksheet $worksheet -Column 10 -Heading "utilization_thisweek" -NumberFormat "Percentage" 
Set-ExcelColumn -Worksheet $worksheet -Column 11 -Heading "utilization_lastweek" -NumberFormat "Percentage" 
Set-ExcelColumn -Worksheet $worksheet -Column 14 -Heading "Average utilization This Week" -NumberFormat "Percentage"
Set-ExcelColumn -Worksheet $worksheet -Column 15 -Heading "Change in Average utilization" -NumberFormat "Percentage"  

# $utilizationStructure | ForEach-Object {
#     $worksheet.Cells[-join $_.keys].Value = $_.values[0]
# }

# Get Row Count
$rowcount_ls = $worksheet.Dimension.Rows

# Delete unrelated data
for ($i = $rowcount_ls; $i -ge 2; $i--) {
    $cell_frequency = $worksheet.Cells[$i, 4]
    $cell_time = $worksheet.Cells[$i, 5]

    if (($cell_frequency.value -ne $frequency) -or ($null -eq $cell_time.value)) {      
        $worksheet.DeleteRow($i)
    }
}


# Asset Type
foreach ($cat in $categories.GetEnumerator()) {

    $asset_id = $cat.Key
    $category = $cat.Value

    2..$rowcount_ls | ForEach-Object {
        if ($asset_id -eq $worksheet.Cells["B$_"].Value) {
            $worksheet.Cells["A$_"].Value = $category
        }
    }
}

# Set only unique values to M column
2..$worksheet.Dimension.Rows | ForEach-Object {
    $worksheet.Cells["A$_"].Value
} | Select-Object -Unique | Sort-Object | ForEach-Object -Begin {
    $Count = 1
} -Process {
    $Count++
    Write-Verbose "Writing value to M$Count with value $_" 
    $worksheet.Cells["M$Count"].Value = $_
    
}

# Because count is still available
2..$Count | ForEach-Object {
     $worksheet.Cells["N$_"].Formula = "=AVERAGEIFS(`$K`:`$K,`$A`:`$A,M$_)"
     $worksheet.Cells["O$_"].Formula = "=AVERAGEIFS(`$K`:`$K,`$A`:`$A,M$_)-AVERAGEIFS(`$J`:`$J,`$A`:`$A,M$_)"

}


2.. $rowcount_ls  | ForEach-Object {
    $worksheet.Cells["H$_"].Formula = "=VLOOKUP(B$_,`'utilization`-new`-hidden`'`!`$A`:`$F,5,0)"  
    $worksheet.Cells["I$_"].Formula = "=VLOOKUP(B$_,`'utilization`-new`-hidden`'`!`$A`:`$F,6,0)"
    $worksheet.Cells["J$_"].Formula = "=G$_/E$_"
    $worksheet.Cells["K$_"].Formula = "=I$_/E$_"
    if ($null -eq $worksheet.Cells["B$_"].value ) {
        $worksheet.DeleteRow($_)
    }

}

<#
-----------------------------------------------
 STEP 7: HIDE SHEETS THAT ARE NOT USED DIRECTLY
-----------------------------------------------
#>

$worksheet = $excelPackage.Workbook.Worksheets["utilization-new-hidden"]
$worksheet.Hidden = [OfficeOpenXml.eWorkSheetHidden]::Hidden

# Close-ExcelPackage -ExcelPackage $excelPackage -Show


<#
------------------------------------
 STEP 8: SHEET INVENTORY
-------------------------------------
#>

$worksheet = $excelPackage.Workbook.Worksheets["inventory"]

Set-ExcelColumn -Worksheet $worksheet -Column 5 -Heading "CoffeeNewID"
Set-ExcelColumn -Worksheet $worksheet -Column 6 -Heading "Alert"
Set-ExcelColumn -Worksheet $worksheet -Column 7 -Heading "UniqueId"
Set-ExcelColumn -Worksheet $worksheet -Column 8 -Heading "Year"
Set-ExcelColumn -Worksheet $worksheet -Column 9 -Heading "WeekNum"

$rowcount = $worksheet.Dimension.Rows

2..$rowcount | ForEach-Object {
    if ($worksheet.Cells["D$_"].Value -match "\|") {
        # Extract characters before the pipe (|)
        $worksheet.Cells["E$_"].Value  = ($worksheet.Cells["D$_"].Value  -split '\s*\|\s*')[0]
    }
    elseif ($worksheet.Cells["D$_"].Value  -like 'Cheese Coffee*') {
        # Extract characters between [ and the first space
        $worksheet.Cells["E$_"].Value  = $worksheet.Cells["D$_"].Value  -replace '^Cheese Coffee \[([^\s]+).*', '$1'
    }
    elseif ( ([regex]::Match($worksheet.Cells["D$_"].Value, '\[([^\]]+)\]')).Success) {
        <# Action when this condition is true #>
        $worksheet.Cells["E$_"].Value = ([regex]::Match($worksheet.Cells["D$_"].Value, '\[([^\]]+)\]')).Groups[1].Value
    }
    elseif($null -ne $worksheet.Cells["D$_"].Value) {
        $worksheet.Cells["E$_"].Value = $worksheet.Cells["D$_"].Value
    }
}


# Data Validation

2..$rowcount | ForEach-Object { #Other than robusta and arabica        
    if ($worksheet.Cells["B$_"].Value -notin ("Arabica","Robusta")) {
            $worksheet.Cells["F$_"].Value = "Abnormal"
        }
    else { #Duplicate Input Validation
        $worksheet.Cells["G$_"].Formula =  "=D$_ & DATEVALUE(TEXT(A$_,`"mm/dd/yyyy hh:mm`")) & HOUR(TEXT(A$_,`"mm/dd/yyyy hh:mm`"))"
        $worksheet.Cells["F$_"].Formula = "=IF(COUNTIF(`$G`:`$G,G$_)`>1,`"Duplicate Record`",`"`")"
    }

    $worksheet.Cells["I$_"].Formula = "WEEKNUM(TEXT(A$_,`"mm/dd/yyyy hh:mm`"),1)" # Week starts from Sun to Sat
    $worksheet.Cells["H$_"].Formula = "YEAR(TEXT(A$_,`"mm/dd/yyyy hh:mm`"))"

    }

$color = [System.Drawing.Color]::Red
Set-ExcelRange -Worksheet $worksheet -Range "F1" -BackgroundColor $color

Set-ExcelColumn -Worksheet $worksheet -Column 7 -Hide



<#
-------------------
STEP 9 : FORECAST
-------------------
#>

# Access the sales worksheet
$worksheet = $excelPackage.Workbook.Worksheets["sales"]

Set-ExcelColumn -Worksheet $worksheet -Column 12 -Heading "Weight" -AutoSize
Set-ExcelColumn -Worksheet $worksheet -Column 1 -Heading "Date" -AutoSize -NumberFormat 'Short Date'
Set-ExcelColumn -Worksheet $worksheet -Column 7 -Heading "Forecast_1" -AutoSize 
Set-ExcelColumn -Worksheet $worksheet -Column 8 -Heading "Forecast_2" -AutoSize 
Set-ExcelColumn -Worksheet $worksheet -Column 9 -Heading "Forecast_3" -AutoSize

# Add Weights
$worksheet.Cells["L2"].Value = 0.1
$worksheet.Cells["L3"].Value = 0.2
$worksheet.Cells["L4"].Value = 0.7


# Add the formula to cell E2 through to E5
5..$worksheet.Dimension.Rows | ForEach-Object {
    $worksheet.Cells["G$_"].Formula = "AVERAGE(B$($_-3):B$($_-1))"
    $worksheet.Cells["H$_"].Formula = "SUMPRODUCT(B$($_-3):B$($_-1),`$L2:`$L4)"
    $worksheet.Cells["I$_"].Formula = "_xlfn.FORECAST.ETS(A$_,B$($_-3):B$($_-1),A$($_-3):A$($_-1))"
    
}

# Tip: To troubleshoot, one way is to see the properties of the cell:
#$worksheet.Cells["I5"]
#$worksheet.Cells["I6"]

Close-ExcelPackage -ExcelPackage $excelPackage

# Add charts (Mimic Forcast Sheet)
$Chart1Splat = @{
        ChartType = 'line'
        XRange    = "Date"
        YRange    = "Sales", "Forecast_1"
        Title     = "Forecast Method 1: Moving Average Sales Of The Last 3 Days"
        TitleBold = $true
        Width     = 800
        Row       = 1
        Column    = 14
        LegendPosition = 'Bottom'
        SeriesHeader = "Sales", "Forecast_1"
    }
$Chart2Splat = @{
        ChartType = 'line'
        XRange    = "Date"
        YRange    = "Sales", "Forecast_2"
        Title     = "Forecast Method 2: Weighted Moving Average Sales Of The Last 3 Days"
        TitleBold = $true
        Width     = 800
        Row       = 21
        Column    = 14
        LegendPosition = 'Bottom'
        SeriesHeader = "Sales", "Forecast_2"
    }
$Chart3Splat = @{
        ChartType = 'line'
        XRange    = "Date"
        YRange    = "Sales", "Forecast_3"
        Title     = "Forecast Method 3: ETS"
        TitleBold = $true
        Width     = 800
        Row       = 41
        Column    = 14
        LegendPosition = 'Bottom'
        SeriesHeader = "Sales", "Forecast_3"
    }



$Chart1 = New-ExcelChartDefinition @Chart1Splat
$Chart2 = New-ExcelChartDefinition @Chart2Splat
$Chart3 = New-ExcelChartDefinition @Chart3Splat

# And let's export it
Export-Excel -Path $result -WorksheetName "sales" -ExcelChartDefinition $Chart1,$Chart2,$Chart3 -Show -AutoNameRange

Write-Output "Finish: $((Get-Date).ToString())"

<#
--------------------------------------
STEP 10 : BONUS - CREATING DASHBOARD
--------------------------------------
#>

$Exportvalues = @{
    Path = $result
    WorksheetName = "dashboard"
    AutoFilter =$true
    IncludePivotTable = $true
    PivotRows = "Shift"
    PivotColumn = "Item"
    PivotData = @{"Quantity"="Sum"}
    PivotFilter =  "WeekNum"

}

Import-Excel -Path $result -WorksheetName "operation" |
Export-Excel @Exportvalues

Invoke-Item $result