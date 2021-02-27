#Requires -RunAsAdministrator


function Create-WebClient {
	return New-Object System.Net.WebClient
}

function Download-File 
{
	param ([string]$fileWebUrl,[string]$destinationFilepath)

	Invoke-WebRequest -Uri $fileWebUrl -OutFile $destinationFilepath
}

function Extract-Archive
{
	param ([string]$archiveFile, [string]$destination)
	
	Expand-Archive -LiteralPath $archiveFile -DestinationPath $destination
}

function Create-Directory
{
	param ([string]$path)

	if ( (Test-Path $path) -Eq $False)
	{
		New-Item -ItemType Directory -Path $path | Out-Null
	}
}

function Append-To-Path
{
	param ([string]$loc)

	[Environment]::SetEnvironmentVariable("Path", $env:Path + $loc, "Machine")	
}

function Is-Choco-Installed
{
    return (Get-Command -Name choco.exe -ErrorAction SilentlyContinue) -Ne $null
}

function Is-Choco-Package-Installed
{
	param ([string]$pkg)


	return ($installedPackages | Where-Object { $_.ToLower().StartsWith($pkg) })
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
if(-Not (Is-Choco-Installed))
{
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
	iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$installedPackages = (powershell choco list -lo)

# Install git
if(-Not (Is-Choco-Package-Installed "git"))
{
	choco install git -y --force 

	Refresh-Path
}

# Install VIM
if(-Not (Is-Choco-Package-Installed "vim"))
{
	choco install vim -y --force --params "'/InstallDir:$toolsDir'"
	Append-To-Path "$toolsDir\vim\vim82\"

	# install vundle
	git clone https://github.com/VundleVim/Vundle.vim.git "$Home\.vim\bundle\Vundle.vim"  

	Refresh-Path
	vim +PluginInstall +qall
}

Download-File "https://raw.githubusercontent.com/stew-dev-github/dotfiles/main/.vimrc" "$Home\.vimrc"

# Install Windows Terminal
if(-Not (Is-Choco-Package-Installed "microsoft-windows-terminal"))
{
	Write-Output "Installing windows terminal"
	choco install -y microsoft-windows-terminal
}

# Update our settings if our copy is different
$wtPackageId = "8wekyb3d8bbwe"
$wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_$wtPackageId\LocalState\settings.json"
Download-File "https://raw.githubusercontent.com/stew-dev-github/dotfiles/main/windows-terminal-settings.json" $wtSettingsPath

# Microsoft SQL Server 2019
if(-Not (Is-Choco-Package-Installed "sql-server-2019"))
{
	choco install -y sql-server-2019 --params "'/IgnorePendingReboot'"
}

# SSMS
if(-Not (Is-Choco-Package-Installed "sql-server-management-studio"))
{
	choco install -y sql-server-management-studio
}

# Jetbrains datagrip
if(-Not (Is-Choco-Package-Installed "datagrip"))
{
	choco install -y datagrip
}

# Rider IDE
if(-Not (Is-Choco-Package-Installed "jetbrains-rider"))
{
	choco install -y jetbrains-rider
}
Download-File "https://raw.githubusercontent.com/stew-dev-github/dotfiles/main/.ideavimrc" "$Home\.ideavimrc"

# Clion IDE
if(-Not (Is-Choco-Package-Installed "clion-ide"))
{
	choco install -y clion-ide
}

# dotCover
if(-Not (Is-Choco-Package-Installed "dotcover"))
{
	choco install -y dotcover
}

# dotTrace
if(-Not (Is-Choco-Package-Installed "dottrace"))
{
	choco install -y dottrace
}

# dotMemory
if(-Not (Is-Choco-Package-Installed "dotmemory"))
{
	choco install -y dotmemory
}

# dotPeek
if(-Not (Is-Choco-Package-Installed "dotpeek"))
{
	choco install -y dotpeek
}

# Brave Browser
if(-Not (Is-Choco-Package-Installed "brave"))
{
	choco install -y brave
}


# Upgrade any existing packages
powershell choco upgrade all -y



