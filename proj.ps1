param([int]$Depth = 3, $Pattern = $null, $Type = "sln")

function FindParentContainingGitRepository {
	param($Item)

	$gitDirectories = Get-ChildItem -Force -Path $Item.FullName -Directory | Where-Object {$_.Name -eq ".git"}

	if($gitDirectories.Count -gt 0) {
		return $Item.Name
	}

	if($Item.FullName -eq $Item.Root.FullName) {
		return ""
	}

	FindParentContainingGitRepository -Item $item.Parent
}

function Main
{
	$slnFiles = Get-ChildItem -Path .\ -Filter "*.$Type" -Recurse -Depth $Depth

	if($pattern -ne $null) {
		$slnFiles = $slnFiles | Where-Object { $_.Name | Select-String -Pattern $pattern -SimpleMatch }
	}

	if($slnFiles.Count -eq 0) {
		Write-Error 'Could not locate any sln files'
		return $null
	}

	if($slnFiles.Count -eq 1) {
		return ($slnFiles | Select-Object -first 1).FullName
	}

	$i = 0;
	Write-Host 
	Write-Host 'Select a sln file to open'
	Write-Host 

	Foreach($sln in $slnFiles) {

		$iStr = $i.ToString().PadLeft(2)
		$parent = FindParentContainingGitRepository -Item $sln.Directory

		Write-Host "[$iStr] ".PadRight(4) -NoNewline

		$padding = 60
		if($parent -ne "") {
			Write-Host "$parent" -NoNewline -Foreground red
			Write-Host "\" -NoNewline
			$padding -= $parent.Length
		}

		$output = "$sln".PadRight($padding) + "`t"
		Write-Host "$output" -NoNewline -Foreground green
		
		$i++

		if(($i % 2) -eq 0) {
			Write-Host
		}
	}

	Write-Host
	Write-Host "[Q] Quit"

	Write-Host
	Write-Host "Selection: " -NoNewline

	$validSelection = $false
	$sel = -1
	do {
		$selected = Read-Host

		if($selected -eq 'q' -or $selected -eq 'Q') {
			return
		}

		$sel = -1
		if(-not([int]::TryParse($selected, [ref]$sel)) -or 
			($sel -lt 0 -or $sel -ge $slnFiles.Count)) {

			Write-Host "Invalid input"
			Write-Host "input: " -NoNewline
			continue
		}


		$validSelection = $true
	}while($validSelection -ne $true)

	return $slnFiles[$sel].FullName
}

Main
