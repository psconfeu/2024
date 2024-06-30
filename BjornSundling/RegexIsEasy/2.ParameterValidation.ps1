# Parameter validation using RegEx

function testSimpleParameterValidation {
    param (
        [ValidatePattern(
            '^[a-z]{3,5}\.[a-zA-Z0-9]{40,}$'
        )]
        $ADODescriptor, # Azure DevOps user descriptor
        
        [ValidatePattern(
            '^(http|HTTP)[sS]?:\/\/'
        )]
        $URL # Used to validate a url

        
    )
    
    Write-Host "Descriptor: $ADODescriptor"
    Write-Host "Url: $URL"
}

testSimpleParameterValidation -ADODescriptor "abc.$('a'*40)"

# Failing a regex check is ugly!
testSimpleParameterValidation -ADODescriptor "abc.$('a'*39)"

break











# But we can fix it!

function testSimpleParameterValidationWithErrorMsg {
    param (
        [ValidatePattern(
            '^[a-z]{3,5}\.[a-zA-Z0-9]{40,}$',
            ErrorMessage = 'ADO Descriptor is in the form of "<3 to 5 lower case letters>.<40 or more letters and/or numbers>'
        )]
        $ADODescriptor, # Azure DevOps user descriptor

        [ValidatePattern(
            '^(http|HTTP)[sS]?:\/\/'
        )]
        $URL # Used to validate a url
    )
    
    Write-Host "Url: $URL"
    Write-Host "Descriptor: $ADODescriptor"
}

# Errormessage makes errors understandable
testSimpleParameterValidationWithErrorMsg -ADODescriptor "abc.$('a'*39)"




# The issue with URLs is still there though..
testSimpleParameterValidationWithErrorMsg -URL 'urigoeshere'




# And in this case the easiest sollution was - Don't use RegEx
function testSimpleParameterValidationWithTypes {
    param (
        [ValidatePattern(
            '^[a-z]{3,5}\.[a-zA-Z0-9]{40,}$',
            ErrorMessage = 'ADO Descriptor is in the form of "<3 to 5 lower case letters>.<40 or more letters and/or numbers>'

        )]
        $ADODescriptor, # Azure DevOps user descriptor

        [ValidateScript({
            $_.ToString().StartsWith('http')
        }, ErrorMessage = 'URL must start with HTTP:// or HTTPS://')]
        [uri]$URL # Used to validate a url
    )
    
    Write-Host "Url: $URL"
    Write-Host "Descriptor: $ADODescriptor"
}


testSimpleParameterValidationWithTypes -URL 'urigoeshere'

testSimpleParameterValidationWithTypes -URL 'https://urigoeshere'


# Remember also - the char class for validation can be quite powerfull, and less RegEx-y..
