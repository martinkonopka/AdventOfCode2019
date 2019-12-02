Function Get-ProgramOutput {
    param(
        [int]$Noun
    ,   [int]$Verb
    )
    $in = (Get-Content .\input.txt).Split(",") | % { [int]$_ }
    $in[1] = $Noun; $in[2] = $Verb;
    
    (0..($in.Count / 4)) `
    | % { $_ * 4 } `
    | % { $take = $true } `
    { 
        if ($take) `
        { 
            $take = ($in[$_] -ne 99)
            if ($take) { $_ }
        }
    } `
    | % { } `
    {
        $left = $in[$in[$_ + 1]]
        $right = $in[$in[$_ + 2]]
        $in[$in[$_ + 3]] = if ($in[$_] -eq 1) { $left + $right } else { $left * $right }
    } `
    { $in[0] }
}

$search = 19690720
$max = 100

1..$max `
| % { $run = $true } `
    { 
        $noun = $_ 
        if ($run) {
            1..$max `
            | % { 
                $verb = $_ 
                if ($run) {
                    $out = Get-ProgramOutput -Noun $noun -Verb $verb
                    $run = $out -ne $search
                    if ($out -eq $search) {
                        Write-Host $noun $verb
                    }
                }
            }
        }
    }