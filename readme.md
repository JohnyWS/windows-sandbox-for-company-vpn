# Get online with sandboxed company VPN

To create better isolation, and to prevent myself to get shut out of my own PC, I created this setup to be able to log on to my company VPN via Windows Sandbox.

## Requirements

1. Windows 10 Professional edition. Home edition does not have it. *If you have MSDN and you're sitting at home, then check your MSDN account and see if you're covered for an upgrade.*
2. Virtualization must be enabled in UEFI/BIOS.

## Get started

### Quick setup

For the quick setup, which includes convention based configs, you can quickly get up and running by following the following steps, but bear in mind that paths will be important!

1. Clone the repo to "C:\virtualization" by using `git clone https://github.com/JohnyWS/cs-go-config.git sandbox`
   *The `sandbox` part in the end is important. That makes sure the full local path is correct.*
2. Enable Windows Sandbox optional feature by running this oneliner in an PowerShell admin prompt:  
   `if((Get-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM').State -ne 'Enabled'){Write-Host 'Enabling feature ...';Enable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM'}Write-Host 'All set!'`  
   *TODO: Document feature and supply other ways of doing the same thing.*
3. Add your rdp files to the [resources folder](template/resources). Read the [suggestions docs](template//ressurces/suggestions.md) for more info.
4. Add your company vpn installer exe to [the software template folder](template/software) but named `company-vpn.exe`
5. Run [template/company-sandbox-runner.wsb](template/company-sandbox-runner.wsb) and you're good to go!

### Scripted setup

To better suit your custom usecase, a templating system has been introduced, that requires you to make local changes, followed by running `/scripts/Initialize-Sandbox.ps1` to get started:

1. Clone this repo (any path and folder name will do)
2. Add your rdp files to the [resources folder](template/resources). Read the [suggestions docs](template//resources/suggestions.md) for more info.
3. Add all the installer exe files you need to [the software template folder](template/software).
4. Run [the init script](scripts/Initialize-Sandbox.ps1).  
   If you haven't installed Windows Sandbox, then run the script in an admin promt and with the `-AutoInstallWindowsSandbox` switch.
5. Run the wsb file from the output folder and you're good to go!

### Even more customization

If the startup script does not do exactly what you need, you can create your own by [copying the existing](template/software/startup.template.cmd) and remove the ".template" part. This startup script will now be used instead, but no replacements will be done, so if you want to have an even better start, you might be better of using the file generated to the output folder as your starting point, because all the relative paths are setup correctly then.

The same *can* be done with the wsb file, but then you've pretty much done it all on your own, and there's not much help from this repo left, as it is right now - do you find yourself needing that, and have other things you'd like to automate, raise a ticket, and we'll have a look at how that can be accomplished.

## Current limitations

1. No multi-screen setup.

## TODO

1. More docs to help people better getting started with prerequesites
2. You tell me! :)
