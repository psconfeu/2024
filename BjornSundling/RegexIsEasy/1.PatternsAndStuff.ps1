'RegEx is hard!' -replace '\w+(?=!)', 'easy' 

break






$RegExString = @'
Hello PSConfEU-2024.
Join me, Björn "~Bjompen~" Sundling.
	Let`s learn some RegEx!
    'Cause RegEx is fun.
It's the Α and Ω of meta languages.
Find me at Mastodon, https://mastodon.nu/@bjompen
'@

break






# Lets look at the basics

$RegExString | Select-String -Pattern '\w' -AllMatches # Match on any word character, including numbers and underscore
$RegExString | Select-String -Pattern '\d' # Matches numbers and numbers only
$RegExString | Select-String -Pattern '\s' -AllMatches # Matches whitespace

# \1 - same as previous group
$RegExString | Select-String -Pattern '(\w)\1' -AllMatches # Match on any double word character, including numbers and underscore


# Pattern dangers
# Newlines
Clear-Host
($RegExString -split '\r')[0]
($RegExString -split '\r')[1]

($RegExString -split '\n')[0]
($RegExString -split '\n')[1]

($RegExString -split '\r\n')[0]
($RegExString -split '\r\n')[1]

# Match anything between A and Ö. Beware! RegEx works with ASCII index number https://www.asciitable.com/
$RegExString | Select-String -Pattern '[a-zA-Z]' -AllMatches
$RegExString | Select-String -Pattern '[a-öA-Ö]' -AllMatches


# But how do we know all this? Pattern remembering? No - https://regex101.com/
$RegExString | clip
Start-Process https://regex101.com/

# And of course - the official docs!
Start-Process https://learn.microsoft.com/en-us/dotnet/standard/base-types/regular-expression-language-quick-reference

break






# But this is about making it easier, right?

# Readable? Add comments!
$RegExString | Select-String -Pattern '(?# This regex will find double letters)(\w)\1' -AllMatches 

# Comments may also be added at the end of a pattern by using (?x)
# This is _actually_ "ignore pattern whitespace", which, well, ignores whitespace that isn't specifically included in a pattern. Warning...
$RegExString | Select-String -Pattern '(\w)\1(?x) # Match on any double word character, including numbers and underscore' -AllMatches


break






#Easier may also mean using clearer ways of pattern recognition.
# I'm from sweden! Unicode named blocks: https://learn.microsoft.com/en-us/dotnet/standard/base-types/character-classes-in-regular-expressions#supported-named-blocks
$RegExString | Select-String -Pattern '\p{IsBasicLatin}' -AllMatches 
$RegExString | Select-String -Pattern '\p{IsGreek}' -AllMatches 
$RegExString | Select-String -Pattern '\p{IsLatin-1Supplement}' -AllMatches 


Start-Process https://wiki.contextgarden.net/List_of_Unicode_blocks

Clear-Host

# How about Turkish - notoriously hard to find?
@'
The Latin-derived letters dotted İ i and dotless I ı,
which are distinct letters in the alphabets of a number of Turkic languages,
unlike in English and most languages using the Latin script,
have caused some issues in computing.
ğ, Ğ, ç, Ç, Ç, Ş, Ş, ü, Ü, Ü, ö, Ö, Ö, ı, İ
'@ | Select-String -Pattern '\p{IsLatin-1Supplement}|\p{IsLatinExtended-A}' -AllMatches

# Or general unicode categories: https://learn.microsoft.com/en-us/dotnet/standard/base-types/character-classes-in-regular-expressions#supported-unicode-general-categories 
$RegExString | Select-String -Pattern '(?# This is maths)\p{Sm}' -AllMatches 

# But how do I know the categories?
$RegExString.ToCharArray() | % {@{ "$([char]::GetUnicodeCategory($_))" = $_} }

# In fact - the char class has lots of cool stuff going for it..
[char] | Get-Member -Static