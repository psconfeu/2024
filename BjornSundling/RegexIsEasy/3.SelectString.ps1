# Select-String is one of my favourite secrets in PowerShell.

$pattern = @"
(?x)
    \w{2,}(?# Any word character, 2 or more times)
    (?![^\s])(?# Negative lookahead - Can _not_ be followed by anything other than whitespace)
"@

# A great way of demoing and testing patterns
'Hello PSConfEU 2024! It`s great to be here' | Select-String -Pattern $pattern

# With all matches.
'Hello PSConfEU 2024! It`s great to be here' | Select-String -Pattern $pattern -AllMatches

break

Clear-Host

# But this is where it gets cool.. File search!

Get-ChildItem .\3.SelectString | Select-String -Pattern 'Error'

Clear-Host

# It can even give us the context!
(Get-ChildItem .\3.SelectString | Select-String -Pattern 'Error' -Context 3)[1]

break

# Story time! PSSecretScanner demo 
code C:\GitHub\bjompen\PSSecretScanner

# It's all select string! (line 92)
# Patterns stolen from OWASP and others

break

Clear-Host


# Sometimes it feels like my arms are just stuck and I can't write easier patterns..
# So instead, lets break them down for readability!

$exPattern1 = 'Error'
$exPattern2 = 'Warning'
$exPattern3 = 'Verbose'
$exPattern4 = 'Debug'

$exPattern = $exPattern1, $exPattern2, $exPattern3, $exPattern4 -join '|'

Get-ChildItem .\3.SelectString | Select-String -Pattern $exPattern -AllMatches # Works well for log searches. Errors or Warnings or...


# You may of course make the patterns even more advanced and use the same principle..
$pattern1 = '\bPS.*U\b'
$pattern2 = '\bI(?=t)'
$pattern3 = '(?<=`)s'
$pattern4 = 'g[a-r]{3}t'

# Then combine them with 'OR', |.
$pattern = $pattern1, $pattern2, $pattern3, $pattern4 -join '|'

'Hello PSConfEU 2024! It`s great to be here' | Select-String -Pattern $pattern -AllMatches 

Clear-Host

# Advanced patterns are often slower than foreach loops though. It may be faster and easier to do four searches,
# But you do get somewhat different results.

$myFiles = Get-ChildItem .\3.SelectString 

$myFiles | Select-String -Pattern $pattern -AllMatches

foreach ($p in @($pattern1, $pattern2, $pattern3, $pattern4)) {
    $myFiles | Select-String -Pattern $p -AllMatches
}