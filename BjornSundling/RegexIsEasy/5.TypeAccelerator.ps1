# [regex] - The type accelerator behind the magic


$operatorString = 'Hello PSConfEU 2024 - And welcome to the world of RegEx!'

# Instead of showing the match, we get a match object
[regex]::Match($operatorString, 'PSConfEU')

# Which contains the data from all other PowerShell regex things..
[regex]::Match($operatorString, 'PSConfEU') | Get-Member

Clear-Host


# All matches.
[regex]::Matches($operatorString, 'e') | Format-Table -AutoSize






# Case sensitivity all of a sudden? 🤔
[regex]::Count($operatorString, 'e')
[regex]::Count($operatorString, 'E')

[regex]::Count($operatorString, '[Ee]')

[regex]::Matches($operatorString, 'e') | Format-Table -AutoSize
[regex]::Matches($operatorString, 'E') | Format-Table -AutoSize

Clear-Host


# Yup - We're case sensitive! \p{Lu} - UpperCase only
[regex]::Matches($operatorString, '\p{Lu}').value -join ''
$operatorString | Select-String -Pattern '\p{Lu}' -AllMatches

$operatorString -replace '\p{Lu}', '@'
[regex]::Replace($operatorString, '\p{Lu}', '@')

Clear-Host


# So we can match, count, replace, and more using the regex accelerator. 
[regex] | Get-Member -Static

Clear-Host



# The "make regex easy" part of the accelerator: Escape.
# Say I want to match a path
$myPath = 'c:\temp\PSConfEU.2024\is-Awesome!'
$myPattern = 'c:\temp\PSConfEU.2024\is-Awesome!'

$myPath -eq $myPattern

[regex]::Match($myPath, $myPattern)

Clear-Host

$myPattern = [regex]::Escape('c:\temp\PSConfEU.2024\is-Awesome!')
$myPattern 

[regex]::Match($myPath, $myPattern)


# Looping back to the begining - Comments works with regexOptions as well
# But as stated - Whitespace needs to be escaped to matter!
[regex]::Matches($operatorString, 'PSConfEU\ \d{4} # Match "PSConfEU 2024". Space char _has_ to be escaped using "\"', 
    [System.Text.RegularExpressions.RegexOptions]::IgnorePatternWhitespace
)

[System.Text.RegularExpressions.RegexOptions] | Get-Member -Static
