$in = (Get-Content .\input.txt).Split(",") | % { [int]$_ }
$in[1] = 12; $in[2] = 2;

(0..($in.Count / 4)) `
| % { $_ * 4 } `
| % { $take = $true } `
    { 
        if ($take) 
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
