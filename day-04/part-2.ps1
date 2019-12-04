136818..685979 `
| % { 
        $orig = $_.ToString().ToCharArray()
        $shifted = ([int]([Math]::Floor($_ / 10))).ToString().ToCharArray()
        1..($orig.Length - 1) | % { $orig[$_] = ([int]::Parse($orig[$_]) - [int]::Parse($shifted[$_ - 1])).ToString()[0] }
        @{ "orig" = $_ ; "proc" = [String]::new($orig) }
    } `
| Where-Object -FilterScript { (-not $_["proc"].Contains("-")) -and ($_["proc"] -match "([^0]0[^0])|([^0]0$)") } `
| Measure-Object `
| Select-Object -Expand Count