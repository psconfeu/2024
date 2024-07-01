$SessionsURI = "https://sessionize.com/api/v2/j7w9zn0t/view/sessions"
$Sessions = (Invoke-RestMethod -Method Get -Uri $SessionsURI).Sessions

$Sessions | Where-Object {$_.ID -eq "590978"}