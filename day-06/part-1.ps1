param(
    [string]$Path = ".\input.txt"
)

$parents = @{ "COM" = $null }
$depths = @{ "COM" = 0 }

Function Get-Depth {
    param(
        [string][Parameter(ValueFromPipeline=$true)]$node    
    )

    process 
    {
        if (-not $depths.ContainsKey($node)) {
            if ($parents.ContainsKey($node)) {
                $depths[$node] = 1 + [int](Get-Depth -Node $parents[$node])
            }
        }
        $depths[$node]
    }
}

Get-Content $Path `
| % { 
        $parts = $_.Split(")")
        $parents[$parts[1]] = $parts[0]
    }

$parents.Keys `
| Get-Depth `
| Measure-Object -Sum `
| Select-Object -Expand Sum

