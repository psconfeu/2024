<#
    
    PowerShell Conference EU 2024
    Antwerp, Belgium

    Evgenij Smirnov (@cj_berlin)

    Connecting to Systems in a Trustless World

    DEMO 04-01: Remote execution via SQL

#>
function Invoke-RemoteShell {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]$Command,
        [Parameter(Mandatory=$false)]
        [string]$ComputerName = 'PSCONF-MS01.psconf.eu'
    )
    $dbConn = New-Object System.Data.SqlClient.SqlConnection("Server=$($ComputerName);User ID=sa;Password=Passw0rd;")
    $dbConn.Open()
    $dbCmd = $dbConn.CreateCommand()
    $dbCmd.CommandText = ('EXEC master..xp_cmdshell ''"{0}"''' -f $Command)
    $dbRdr = $dbCmd.ExecuteReader()
    while ($dbRdr.Read()) {
        Write-Host $dbRdr[0]
    }
    $dbRdr.Close()
    $dbRdr.Dispose()
    $dbConn.Close()
}
break
#region where am I?
Invoke-RemoteShell -Command 'hostname' -ComputerName 'PSCONF-MS01.psconf.eu'
#endregion
#region who am I?
Invoke-RemoteShell -Command 'whoami' -ComputerName 'PSCONF-MS01.psconf.eu'
#endregion