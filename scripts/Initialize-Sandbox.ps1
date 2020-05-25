param(
  [switch]$SkipPause)
# Script for initializing the the Windows Sandbox configuration for first time use.

$InformationPreference = 'Continue' # Enables the use of Write-Information
$ErrorActionPreference = 'Inquire' # Halts the script so the user actually sees there's an error

$repoRoot = Resolve-Path "$PSScriptRoot/.."
$outputDir = "$repoRoot/output"
$templateDir = "$repoRoot/template"
$ressourcesDir = "$templateDir/ressources"
$softwareDir = "$templateDir/software"
$copyRessourcesDir = $true

if((Get-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM').State -ne 'Enabled') {
  Write-Information 'Enabling feature ...'
  Enable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM'
}

if(Test-Path $outputDir) {
  Write-Warning "Outputfolder already exists. The folder ($outputDir) will now be deleted. Input 'All' to make sure all files are correctly deleted to continue this operation."

  Remove-Item $outputDir -Recurse -Confirm -Force

  if(Test-Path $outputDir) {
    Write-Warning "Not all files where deleted, and execution can not continue. Aborting ..."
    if(-not $SkipPause) {
      pause
    }
    return
  }
}

New-Item $outputDir -ItemType Directory

if(Get-ChildItem $ressourcesDir -Exclude 'suggestions.md') {
  Write-Information 'Copying ressources dir to output ...'
  Copy-Item $ressourcesDir $outputDir -Recurse -Exclude 'suggestions.md'
} else {
  Write-Information 'No files found in template/ressources. Skipping this directory entirely ...'
  $copyRessourcesDir = $false
}

[bool]$useCustomStartupCmd = Test-Path "$softwareDir/startup.cmd"
$installerFiles = Get-ChildItem $softwareDir -Filter '*.exe' -Recurse

if(-not $useCustomStartupCmd -and -not $installerFiles) {
  Write-Warning 'No .exe installers were found. Aborting ...'
  if(-not $SkipPause) {
    pause
  }
  return
}

Write-Information 'Copying template/software folder ...'
Copy-Item $softwareDir $outputDir -Recurse -Exclude 'startup.template.cmd'

if($useCustomStartupCmd) {
  Write-Information 'Using the custom startup.cmd without modifications.'
} else {
  Write-Information 'Modifying startup.template.cmd (and renaming to startup.cmd) ...'
  $startupCmd = [IO.File]::ReadAllText("$softwareDir/startup.template.cmd")

  # Changing current folder in order to calculate relative paths correctly
  Push-Location $softwareDir
  try {
    $relativeInstallerPaths = $installerFiles.FullName |
      Resolve-Path -Relative
  }
  finally {
    Pop-Location
  }

  $newInstallCommand = ($relativeInstallerPaths.Substring(1) |
    ForEach-Object { "start /wait C:\Users\WDAGUtilityAccount\Desktop\software$_ /passive" }) -join "`n"
  
  $startupCmd = $startupCmd -replace '(Installing company VPN [\s.]+)start.+', "`$1$newInstallCommand"

  if (-not $copyRessourcesDir) {
    # removing references to the ressource folder from the startup script
    $startupCmd = $startupCmd -replace 'echo 2\. Run RDP.+\s+start.*ressources$', ''
  }

  [IO.File]::WriteAllText("$outputDir/software/startup.cmd", $startupCmd)
}

Write-Information 'Output folder generated successfully!'
# TODO: Still missing wsb file handling