param(
    [string]$Path = ".\input.txt"
)

$parents = @{ "COM" = $null }

Function Get-PathTo {
    param(
        [string]$node
    ,   [string]$target
    )

    $path = New-Object "System.Collections.Generic.HashSet[string]"
    
    while ($node -ne $target) {
        $node = $parents[$node]
        $path.Add($node) | Out-Null
    }

    , $path
}

Get-Content $Path `
| % { 
        $parts = $_.Split(")")
        $parents[$parts[1]] = $parts[0]
    }

$santaPath = Get-PathTo -Node "SAN" -Target "COM"
$youPath   = Get-PathTo -Node "YOU" -Target "COM"

$santaPath.SymmetricExceptWith($youPath)
$santaPath.Count