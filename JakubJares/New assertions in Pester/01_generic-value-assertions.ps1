# pipeline syntax
1 | Should-Be -Expected 1 # pass
@(1) | Should-Be -Expected 1 # pass

2 | Should-Be -Expected 1

1 | Should-Be -Expected 1, 2

1, 2 | Should-Be -Expected 1

$null | Should-Be 1

# parameter syntax
Should-Be -Actual 1 -Expected 1 # pass

Should-Be -Actual @(1) -Expected 1

# special cases
'$null' | Should-Be $null
'' | Should-Be 'Jakub'


