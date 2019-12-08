param(
    [string]$InputPath = ".\input.txt"
,   [int]$LayerWidth = 25
,   [int]$LayerHeight = 6
)


Get-Content -Path $InputPath `
| % { $_.ToCharArray() } `
| Group-Object -Property { [Math]::Floor($script:counter++ / ($script:LayerWidth * $script:LayerHeight)) } `
| % { [string]::new($_.Group) } `
| Sort-Object { ($_ | Select-String '0' -AllMatches | Select-Object -ExpandProperty "Matches" | Measure-Object | Select-Object -ExpandProperty Count) } `
| Select-Object -First 1 `
| % { 
        ($_ | Select-String '1' -AllMatches | Select-Object -ExpandProperty "Matches" | Measure-Object | Select-Object -ExpandProperty Count) `
      * ($_ | Select-String '2' -AllMatches | Select-Object -ExpandProperty "Matches" | Measure-Object | Select-Object -ExpandProperty Count) 
}
