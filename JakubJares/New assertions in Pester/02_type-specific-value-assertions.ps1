# boolean
$true | Should-BeTrue # pass

1 | Should-BeTrue

"false" | Should-BeTrue

$null | Should-BeTrue

# vs
# pass
1 | Should-BeTruthy
# pass
1 | Should-Be $true


# string
"abc" | Should-BeString "abc" # pass
"ABC" | Should-BeString "abc" # pass

"ABC" | Should-BeString "abc" -CaseSensitive

" a b c " | Should-BeString "abc" -IgnoreWhitespace # pass
" a b c " | Should-BeString "abc" -TrimWhitespace

1 | Should-BeString "abc"

"abc" | Should-BeLikeString "*bc" # pass
"def" | Should-BeLikeString "*bc"