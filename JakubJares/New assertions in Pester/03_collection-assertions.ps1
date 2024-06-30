# pass
@(1) | Should-BeCollection -Expected @(1) 
# pass
1 | Should-BeCollection -Expected @(1)

@(1, 2, 3) | Should-BeCollection @(3, 4, 5)




