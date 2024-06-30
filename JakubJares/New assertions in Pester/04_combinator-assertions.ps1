# pass
@(1, 2, 3) | Should-All { $_ -gt 0 }

@(1, 2, 3) | Should-All { $_ -lt 2 }

@(1, 2, 3) | Should-All { $_ | Should-BeLessThan 2 }

# pass
@(1, 2, 3) | Should-Any { $_ | Should-BeLessThan 2 }

@(1, 2, 3) | Should-Any { $_ | Should-BeGreaterThan 4 }
