# -Replace, -Match, and -Split
$operatorString = 'Hello PSConfEU 2024 - And welcome to the world of RegEx!'


# PowerShell has a number of RegEx capable operators. In most cases they work like expected.
$operatorString -split '[\d\s-]{2,}'

Clear-Host

$operatorString -Match 'PSConfEU\s+20\d{2}'

Clear-Host

$operatorString -Replace '\s\d+' # Can be run with no adition replacement

Clear-Host

$operatorString -Replace '\d+', 'every year!' # or with  replacement string

Clear-Host




# One oddity in PowerShell compared to other languages RegEx - PowerShell is by default not case sensitive.
# So in order for it to behave like most other languages RegEx - add C

$operatorString -Match 'psconfeu' # Match case insensitive
$operatorString -CMatch 'psconfeu' # CMatch case sensitive

Clear-Host

# Same goes for -Replace / -CReplace and -Split / -CSplit
$operatorString -Replace 'WORLD', 'weirdness' # Replace case insensitive
$operatorString -CReplace 'WORLD', 'weirdness' # CReplace case sensitive

Clear-Host




# Replacement and $Matches

$operatorString -CMatch 'P\w+U' # Match sets the magic variable $Matches
$Matches

Clear-Host


$operatorString -CMatch '.*(P\w+U)\s+(\d+).*' # Adding capture groups, (), gives us detailed matches
$Matches

Clear-Host

# And why is this important? -Replace!
$operatorString -CReplace '.*(P\w+U)\s+(\d+).*', '$1 $2 is awesome!'

Clear-Host

# Remember the quotation marks!
$operatorString -CReplace '.*(P\w+U)\s+(\d+).*', "$1 $2 is awesome!"

Clear-Host


# Even better - Use named capture groups. (?<nameOfCapture>pattern)
$operatorString -CMatch '.*(?<conference>P\w+U)\s+(?<year>\d+).*'
$Matches

$operatorString -CReplace '.*(?<conference>P\w+U)\s+(?<year>\d+).*', '${conference} ${year} is awesome!'

Clear-Host




# Other cool features!

$operatorString -replace "\d{4}", {return [int]$_.Value+1} # -Replace can use scriptblocks - Add a year

Clear-Host

'PowerShell', 'Python', 'Perl', 'JavaScript' -match '^P' # Match can act like a filter

Clear-Host
