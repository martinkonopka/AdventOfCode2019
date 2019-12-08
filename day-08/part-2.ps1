param(
    [string]$InputPath = ".\input.txt"
,   [int]$LayerWidth = 25
,   [int]$LayerHeight = 6
)


$image = (Get-Content -Path $InputPath `
| % { $_.ToCharArray() } `
| Group-Object -Property { [Math]::Floor($script:counter++ / ($script:LayerWidth * $script:LayerHeight)) } `
| % { [string]::new($_.Group) }) ` -join "`n"


0..($LayerWidth * $LayerHeight - 1) `
| % { 
        $image `
        | Select-String "(?m)^`\d{$_}(?<a>`\d)`\d*$" -AllMatches `
        | Select-Object -ExpandProperty Matches `
        | Select-Object -ExpandProperty Groups `
        | Where-Object -FilterScript { $_.Name -eq "a" } `
        | Select-Object -Expand Value `
        | Where-Object { $_ -ne 2 } `
        | Select-Object -First 1
    } `
| Group-Object -Property { [Math]::Floor($script:counter2++ / $script:LayerWidth) } `
| % { Write-Host $_.Group }