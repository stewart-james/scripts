$repo = "microsoft/winget-cli"
$releases = "https://api.github.com/repos/$repo/releases"

Write-Host Determining latest release
$latestRelease = (Invoke-WebRequest $releases | ConvertFrom-Json)[0]
$latestAsset = $latestRelease.assets | Where { $_.name.Contains("msixbundle") }

if( -not(Test-Path -Path $latestAsset.Name -PathType Leaf)) {
    Invoke-WebRequest $latestAsset.browser_download_url -Out $latestAsset.name
}

Add-AppxPackage $latestAsset.name

winget install Microsoft.WindowsTerminal --accept-source-agreements
winget install Git.Git
winget install Microsoft.VisualStudioCode
winget install vim.vim
winget install JetBrains.Rider