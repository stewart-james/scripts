#Requires -RunAsAdministrator

function Create-Directory
{
	param ([string]$path)

	if ( (Test-Path $path) -Eq $False)
	{
		New-Item -ItemType Directory -Path $path | Out-Null
	}
}

function Is-Choco-Package-Installed
{
	param ([string]$pkg)


	return ($installedPackages | Where-Object { $_.ToLower().StartsWith($pkg) }) -Ne $Null
}

function Refresh-Path
{
	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
}


#!

$downloadDir = "$HOME\tmp_download"
$toolsDir = "$HOME\tools"

Create-Directory $downloadDir
Create-Directory $toolsDir

# Install Chocolatey
if((Get-Command -Name choco.exe -ErrorAction SilentlyContinue) -Eq $null)
{
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
	iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$installedPackages = (powershell choco list -lo)


$packages = (Get-Content dev-packages.json) | ConvertFrom-Json

ForEach($pkg in $packages.packages)
{
	$name = $pkg.name;
	$refreshPath = ($pkg.refreshPath -Eq $True)
	$commands = ($pkg.additionalCommands)
	$params = ($pkg.params)

	if(-Not (Is-Choco-Package-Installed $name))
	{
		if($params -Ne $Null)
		{
            # ensure we force evalutation of any PS variables used in params (e.g $home)
			Invoke-Expression "choco install $name -y --force --params $params"
		}
		else
		{
			choco install $name -y --force
		}	
		if($refreshPath -Eq $True)
		{
			Refresh-Path
		}

		if(-Not ($commands -Eq $Null))
		{
			ForEach($cmd in $commands)
			{
				Invoke-Expression $cmd
			}		
		}
	}
}

# Upgrade any existing packages
powershell choco upgrade all -y