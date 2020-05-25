param(
  [switch]$AutoInstallWindowsSandbox,
  [switch]$SkipPause)
# Script for initializing the the Windows Sandbox configuration for first time use.

$InformationPreference = 'Continue' # Enables the use of Write-Information
$ErrorActionPreference = 'Inquire' # Halts the script so the user actually sees there's an error

$repoRoot = Resolve-Path "$PSScriptRoot\.."
$outputDir = "$repoRoot\output"
$templateDir = "$repoRoot\template"
$ressourcesDir = "$templateDir\ressources"
$softwareDir = "$templateDir\software"
$copyRessourcesDir = $true

if($AutoInstallWindowsSandbox -and (Get-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM').State -ne 'Enabled') {
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
  Write-Information 'No files found in .\template\ressources. Skipping this directory entirely ...'
  $copyRessourcesDir = $false
}

[bool]$useCustomStartupCmd = Test-Path "$softwareDir\startup.cmd"
$installerFiles = Get-ChildItem $softwareDir -Filter '*.exe' -Recurse

if(-not $useCustomStartupCmd -and -not $installerFiles) {
  Write-Warning 'No .exe installers were found. Aborting ...'
  if(-not $SkipPause) {
    pause
  }
  return
}

Write-Information 'Copying .\template\software folder ...'
Copy-Item $softwareDir $outputDir -Recurse -Exclude 'startup.template.cmd'

if($useCustomStartupCmd) {
  Write-Information 'Using the custom startup.cmd without modifications.'
} else {
  Write-Information 'Modifying startup.template.cmd (and renaming to startup.cmd) ...'
  $startupCmd = [IO.File]::ReadAllText("$softwareDir\startup.template.cmd")

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

  [IO.File]::WriteAllText("$outputDir\software\startup.cmd", $startupCmd)
}

[string[]]$wsbFiles = (Get-ChildItem -Path $templateDir -Filter '*.wsb' -Exclude '*.template.wsb').FullName
if($wsbFiles) {
  if ($wsbFiles.Length -gt 1) {
    Write-Warning 'Only one (1) custom wsb file is supported currently! Aborting ...'
    if(-not $SkipPause) {
      pause
    }
    return
  }

  if(-not $useCustomStartupCmd) {
    Write-Warning 'Currently mixed mode of using startup.template.cmd and custom wsb file is unsupported. Either both must be custom or none of them. Aborting ...'
    if(-not $SkipPause) {
      pause
    }
    return
  }

  Write-Information 'Using the custom wsb file without modifications.'

  Copy-Item $wsbFiles[0] $outputDir
} else {
  Write-Information 'Modifying company-sandbox-runner.template.wsb to use local paths ...'
  $wsb = [IO.File]::ReadAllText("$templateDir\company-sandbox-runner.template.wsb")

  # Fixing mapped folder paths
  $wsb = $wsb -replace "(?s)(<(MappedFolder)>\s+<(HostFolder)>)[\w:\\.-]+(\\(?:ressources|software)</\3>.*?</\2>)", "`$1$outputDir`$4"
  if (-not $copyRessourcesDir) {
    $wsb = $wsb -replace "(?s)\s+<(MappedFolder)>\s+<(HostFolder)>[\w:\\.-]+\\ressources</\2>.*?</\1>", ''
  }

  # Fixing command path
  $wsb = $wsb -replace "(?s)(<(LogonCommand)>\s+<(Command)>)[\w:\\.-]+(\\software\\startup)\.template(\.cmd</\3>\s+</\2>)", "$`1$outputDir`$4`$5"

  [IO.File]::WriteAllText("$outputDir\company-sandbox-runner.wsb", $wsb)
}

Write-Information 'Output folder generated successfully!'
if(-not $SkipPause) {
  pause
}