<#
.SYNOPSIS   
This code is to automate the estimation and sales forecast
    
.DESCRIPTION 
It works by consolidating different excel files and performing calculation


.NOTES   
DateUpdated: 2024-06-16
Version: 1.0


.EXAMPLE   
.\psconf2024-init.ps1
This file contains all parameters needed to run the code
#>

param(
    $result = "..\Result\result.xlsx",
    $inventory = "..\Data\inventory.xlsx",
    $operationFileName = "..\Data\operation_w.xlsx",
    $sales = "..\Data\sales.csv",
    $utilizationFileName = "..\Data\asset_w.xlsx",
    $estimation = "..\Data\estimation.csv"

)

#REPORTING TIME:
$year = 2024
Write-Output "Is The current YEAR correct? $year"
$currentDate = Get-Date
$calendar = [System.Globalization.CultureInfo]::CurrentCulture.Calendar
$weekNumber = $calendar.GetWeekOfYear($currentDate, [System.Globalization.CalendarWeekRule]::FirstDay, [DayOfWeek]::Monday) -1
$last_week_utilization = $utilizationFileName -replace '\.xlsx',"$($Weeknumber-1).xlsx"
$this_week_utilization = $utilizationFileName -replace '\.xlsx',"$($Weeknumber).xlsx"
$operation = $operationFileName -replace '\.xlsx',"$($Weeknumber).xlsx"
# $Plan = $PlanFileName -replace '\.xlsx'," $($Weeknumber)-$($Weeknumber+1).xlsx"

Write-Output "Is The current WEEK correct? $weekNumber"


#DELETE:
$ws_delete_sheet = @("utilization", "utilization-new-hidden","operation","sales")
$ws_delete_rows = "inventory"


#utilization TABLE
$utilizationStructure = 
    @{ 'A1' = "Asset Type"},
    @{ 'B1' = "Asset Number"},
    @{ 'C1' = "Description"},
    @{ 'D1' = "Frequency"},
    @{ 'E1' = "Capacity"},
    @{ 'F1' = "Date_lastweek"},
    @{ 'G1' = "Reading_lastweek"},
    @{ 'H1' = "Date_thisweek"},
    @{ 'I1' = "Reading_thisweek"},
    @{ 'J1' = "utilization_lastweek"},
    @{ 'K1' = "utilization_thisweek"},
    @{ 'M1' = "Asset Type Summary"},
    @{ 'N1' = "Average utilization This Week"},
    @{ 'O1' = "Change in Average utilization"}


#FREQUENCY:
$frequency = "Hours"

# #COFFEE TYPE
# $capcity = @{
#     @("Coconut Coffee") = ""
#     @("Durian Coffee") = ""
#     @("Egg York Coffee") = ""
#     @("Cheese Coffee") = ""
# }

#CATEGORIES
$categories = @{
    @("MC 11","MC 12","MC 13") = "Pour-Over Coffee Maker"
    @("MC 21","MC 22","MC 23") = "Espresso Coffee Maker"
    @("MC 31","MC 32","MC 33") = "All-in-One Coffee Maker"
}

