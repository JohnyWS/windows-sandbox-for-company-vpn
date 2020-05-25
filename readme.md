# Get online with sandboxed company VPN

To create better isolation, and to prevent myself to get shut out of my own PC, I created this setup to be able to log on to my company VPN via Windows Sandbox.

## Requirements

1. Windows 10 Professional edition. Home edition does not have it. *If you have MSDN and you're sitting at home, then check your MSDN account and see if you're covered for an upgrade.*
2. Virtualization must be enabled in UEFI/BIOS.

## Get started

1. Clone the repo to "C:\virtualization" by using `git clone https://github.com/JohnyWS/cs-go-config.git sandbox`
   *The `sandbox` part in the end is important. That makes sure the full local path is correct.*
2. Enable Windows Sandbox optional feature by running this oneliner in an PowerShell admin prompt:  
   `if((Get-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM').State -ne 'Enabled'){Write-Host 'Enabling feature ...';Enable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM'}Write-Host 'All set!'`  
   *TODO: Document feature and supply other ways of doing the same thing.*
3. Add your rdp files to the ressources folder. Read the /ressources/suggestions.md for more info.
4. Add your company vpn installer exe to `/software` but named `company-vpn.exe`
5. Run `/company-sandbox-runner.wsb` and you're good to go!

## Current limitations

1. The hardcoded paths are there, because variables are not, yet, supported - so for now, the "get started" section must be followed to the letter, or changes must be made if you deviate from the instructions.
2. No multi-screen setup.

## TODO

1. More docs to help people better getting started
2. Scripting help that can fix some of the hardcodings in here
3. You tell me! :)
