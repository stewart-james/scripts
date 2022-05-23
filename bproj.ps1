param([char]$t = 'b')

$path = proj
if($path -eq $null) {
	return
}

switch($t) {
	'b' { dotnet build $path; break}
	'p' { dotnet publish $path; break}
	'r' { dotnet restore $path; break}
	't' { dotnet test $path -v q; break}
	'c' { dotnet clean $path; break}
}
