
# What is equivalency?

# false, not the same instance
# even though the shape is the same
([PSCustomObject]@{ Name = 'Jakub' }) -eq  ([PSCustomObject]@{ Name = 'Jakub' })

# if there was -equivalent operator then
# true, different instances but same shape
([PSCustomObject]@{ Name = 'Jakub' }) -equivalent  ([PSCustomObject]@{ Name = 'Jakub' })


# DEMO 1 - pass
$expected = [PSCustomObject] @{
    Name = "Jakub"
    Age = 36
    Languages = "PowerShell", "C#"
}

$actual = [PSCustomObject] @{
    Name = "Jakub"
    Age = 36
    Languages = "C#", "PowerShell"
} 

$actual | Should-BeEquivalent $expected

# DEMO 2 - fail
$expected = [PSCustomObject] @{
    Name = "Jakub"
    Age = 36
    Languages = "PowerShell", "C#", "TypeScript"

    DrinksCoffee = $true
}

$actual = [PSCustomObject] @{
    Name = "Jakub"
    Age = 36
    Languages = "PowerShell", "C#"

    HasSmallKeyboard = $true
}

$actual | Should-BeEquivalent $expected

# DEMO 3 - pass, exclude paths not on expected
$expected = [PSCustomObject] @{
    Name = "Jakub"
    Age = 36
    Languages = @( 
        [PSCustomObject]@{ Name = "PowerShell" }
        [PSCustomObject]@{ Name = "C#" }
    )
}

$actual = [PSCustomObject] @{
    Name = "Jakub"
    Age = 36
    Languages = @( 
        [PSCustomObject]@{ Name = "PowerShell"; Paradigm = "Scripting"  <# <-- #> }
        [PSCustomObject]@{ Name = "C#";  Paradigm = "OOP" <# <-- #> }
    )

    HasSmallKeyboard = $true  <# <-- #>
    HasBigDisplay = $true  <# <-- #>
} 
    
Should-BeEquivalent -Actual $actual -Expected $Expected -ExcludePathsNotOnExpected




