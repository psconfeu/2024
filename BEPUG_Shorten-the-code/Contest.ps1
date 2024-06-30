# Original code
Do{
    $Web = Invoke-WebRequest https://official-joke-api.appspot.com/random_joke
    $Joke = $Web.Content | ConvertFrom-Json
    }While($Joke.type -ne "programming")
    Write-Output $Joke.setup
    Start-Sleep 3
    Write-Output $Joke.punchline

# Winning code
# 85 Chars long
irm official-joke-api.appspot.com/jokes/programming/random|%{$_|% s*;sleep 3;$_|% p*}

%{$_|% s*;sleep 3;$_|% p*}

%{ -> Foreach-Object on all the objects retrieved from the API
$_|% s* -> Pipe the current object into ForEach-Object 
           s* is a pattern that matches any property starting with "s" (in this case, setup).
sleep 3 -> sleep 3
$_|% p* -> Pipe the current object into ForEach-Object
           p* is a pattern that matches any property starting with "p" (in this case, punchline).

#90 chars long
($x=irm official-joke-api.appspot.com/jokes/programming/random).setup;sleep 3;$x.punchline



