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


Function Get-Length {
    param([int]$from, [int]$to) 
        [int]([Math]::Abs([float]($to - $from)))
}


$sort = { $input | Sort-Object -Property { $_[0] }, { $_[1] } }


# Beware, ineffective solution
(Get-Content $Path `
| % {
        $isFirst = $true;
        $lines = @([System.Collections.ArrayList]::new(), [System.Collections.ArrayList]::new()) 
    } `
    {
        $_.Split(",") `
        | Read-Direction `
        | % { $start = @(0, 0); $length = 0 } `
            { 
                $end = Move-Point -Origin $start -Delta $_
                $line = @($start, $end)
                
                $start = $end
            
                @{ Dir = $_.Dir; Line = $line ; Length = $length }

                $length += Get-Length -From $line[0][$_.Dir] -To $line[1][$_.Dir]
            } `
        | % {
                if ($isFirst) {
                    $lines[$_.Dir].Add(@( $_.Line[0], $_.Line[1], $_.Length )) | Out-Null
                } 
                else {
                    $current = $_
                    $lines[1 - $current.Dir] `
                    | % {
                            $a = $_ | & $sort
                            $b = $current.Line | & $sort

                            $intersection = Get-Intersection -A $a -B $b -Dir $current.Dir
                            if ($intersection) {
                                return $_[2] `
                                    + (Get-Length -From $_[0][1 - $current.Dir] -To $intersection[1 - $current.Dir]) `
                                    + $current.Length `
                                    + (Get-Length -From $current.Line[0][$current.Dir] -To $intersection[$current.Dir])
                            }
                        }
                }
            }

        $isFirst = $false
    }) `
    | Measure-Object -Minimum `
    | Select-Object -Expand Minimum