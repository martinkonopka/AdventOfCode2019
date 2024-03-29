param(
    [string]$Path = "$PSScriptRoot\input.txt"
)

Function Read-Direction {
    param([string][Parameter(ValueFromPipeline=$True)]$Command)
    process {
        if ($Command -match "((?<horizontal>[LR])|(?<vertical>[UD]))(?<length>[0-9]+)") {
            $mod = 1;
            $dir = 0;
            if (($Matches.horizontal -eq "L") -or ($Matches.vertical -eq "D")) { $mod = -1 }
            if ($Matches.vertical) { $dir = 1 }
         
            [PSCustomObject]@{ Dir = $dir ; Length = [int]($Matches.length) * $mod }
        }
    }
}


Function Move-Point
{
    param(
        [int[]]$Origin
    ,   [PSObject]$Delta
    )

    $result = $Origin.clone()
    $result[$Delta.Dir] += $Delta.Length
    $result
}


Function Get-Intersection {
    param(
        [int[][]][Parameter(ValueFromPipeline=$true)]$A
    ,   [int[][]]$B
    ,   [int]$Dir
    )

    process {
        $p = @($A, $B)
        $other = 1 - $Dir

        if (($p[$Dir][0][1] -le $p[$other][0][1]) -and ($p[$other][0][1] -le $p[$Dir][1][1]) `
         -and ($p[$other][0][0] -le $p[$Dir][0][0]) -and ($p[$Dir][0][0] -le $p[$other][1][0]))
        {
            @($p[$Dir][0][0], $p[$other][0][1])
        }
    }
}


$sort = { $input | Sort-Object -Property { $_[0] }, { $_[1] } }


Get-Content $Path `
| % {
        $isFirst = $true;
        $lines = @([System.Collections.ArrayList]::new(), [System.Collections.ArrayList]::new()) 
    } `
    {
        $_.Split(",") `
        | Read-Direction `
        | % { $start = @(0, 0) } `
            { 
                $end = Move-Point -Origin $start -Delta $_
                $line = @($start, $end)

                $start = $end

                @{ Dir = $_.Dir; Line = $line }
            } `
        | % {
                if ($isFirst) {
                    $lines[$_.Dir].Add($_.Line) | Out-Null
                } 
                else {
                    $b = $_.Line | & $sort
                    
                    , ($lines[1 - $_.Dir] | % { , ($_ | & $sort) } | Get-Intersection -B $b -Dir $_.Dir)
                }
            }

        $isFirst = $false
    } `
    | % { 
            [int]([Math]::Abs([float]$_[0])) + [int]([Math]::Abs([float]$_[1]))
        } `
    | Where-Object { $_ -gt 0 } `
    | Measure-Object -Minimum `
    | Select-Object -Expand Minimum
