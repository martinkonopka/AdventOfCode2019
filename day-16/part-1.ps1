[CmdletBinding()]
param(
    [String]$Path = "input.txt"
,   [int]$Repeats = 100
)

$Verbose = $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent

function Get-Transform {
    param(
        [int[]]$Sequence
    ,   [int[][]]$Indices
    ,   [int[][]]$Signs
    )

    $copy = $Sequence.Clone()

    
# # the number of threads
# $count = $Sequence.Count

# # the pool will manage the parallel execution
# $pool = [RunspaceFactory]::CreateRunspacePool(1, $count)

# try {    
#     $pool.Open()

#     # create and run the jobs to be run in parallel
#     $jobs = New-Object object[] $count
#     $script = {
#         param(
#             [int[]]$Sequence
#         ,   [int[]]$Indices
#         ,   [int[]]$Signs
#         )


#         $value = 0
#         foreach ($factorIndex in 0..($Indices.Count - 1))
#         {
#             # Write-Host "FactorIndex $factorIndex"
#             # Write-Host "Indices[$index]: $($Indices[$index][$factorIndex])"
#             # Write-Host "Signs[$index]: $($Signs[$index][$factorIndex])"
#             $value += $Sequence[$Indices[$factorIndex]] * $Signs[$factorIndex]
#         }
        
#        [System.Math]::Abs($value % 10)
#     };

#     for ($i = 0; $i -lt $count; $i++) {
#         $ps = [PowerShell]::Create()
#         $ps.RunspacePool = $pool

#         # add the script block to run
#         [void]$ps.AddScript($script)

#         # optional: add parameters
#         [void]$ps.AddParameter("Sequence", $copy)
#         [void]$ps.AddParameter("Indices", $Indices[$i])
#         [void]$ps.AddParameter("Signs", $Signs[$i])

#         # start async execution
#         $jobs[$i] = [PSCustomObject]@{
#             PowerShell = $ps
#             AsyncResult = $ps.BeginInvoke()
#         }
#     }
#     for ($i = 0; $i -lt $count; $i++)
#     {
#         try {
#             $job = $jobs[$i]
#             # wait for completion
#             [void]$job.AsyncResult.AsyncWaitHandle.WaitOne()

#             # get results
#             $Sequence[$i] = $job.PowerShell.EndInvoke($job.AsyncResult) | Select-Object -First 1
#         }
#         finally {
#             $job.PowerShell.Dispose()
#         }
#     }
# }
# finally {
#     $pool.Dispose()
# }

    
    foreach ($index in 0..($Sequence.Count - 1)) 
    {
        Write-Verbose "index: $index"
        Write-Verbose "Indices: $($Indices[$index])"
        Write-Verbose "Signs: $($Signs[$index])"
        $value = 0

        if ($Indices[$index].Count -gt 0) 
        {
            foreach ($factorIndex in 0..($Indices[$index].Count - 1))
            {
                # Write-Host "FactorIndex $factorIndex"
                # Write-Host "Indices[$index]: $($Indices[$index][$factorIndex])"
                # Write-Host "Signs[$index]: $($Signs[$index][$factorIndex])"
                $value += $copy[$Indices[$index][$factorIndex]] * $Signs[$index][$factorIndex]
            }
        }

        $Sequence[$index] = [System.Math]::Abs($value % 10)
    }

    , $Sequence
}

$sequence = (Get-Content -Path $Path) -split "" | % { if ($_ -match '\d') { [int]$_ } }
$length = $sequence.Count

$factorIndices = [int[][]]::new($length)
$factorSigns = [int[][]]::new($length)

$factors = @(0, 1, 0, -1)

Write-Verbose "Generating index"

1..$length `
| % {
        $index = $_
        0..$length `
        | % { $counter = 0 ; $factorIndex = 0; $factorCounter = 0 ; $indices = New-Object System.Collections.ArrayList ; $signs = New-Object System.Collections.ArrayList } `
            {
                if ($factors[$factorIndex] -ne 0)
                {
                    $indices.Add($factorCounter - 1) | Out-Null
                    $signs.Add($factors[$factorIndex]) | Out-Null
                    $counter++
                }
                
                if (++$factorCounter % $index -eq 0)
                {
                    $factorIndex = ($factorIndex + 1) % $factors.Count
                }
            } `
            { $factorIndices[$index - 1] = $indices; $factorSigns[$index - 1] = $signs } 
    }
 

Write-Verbose "Evaluating phases"

while ($Repeats-- -gt 0) 
{
    $sequence = Get-Transform -Sequence $sequence -Indices $factorIndices -Signs $factorSigns -Verbose:$Verbose
}

$sequence | Select-Object -First 8