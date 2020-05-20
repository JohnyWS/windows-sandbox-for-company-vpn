# Get online with sandboxed company VPN

To create better isolation, and to prevent myself to get shut out of my own PC, I created this setup to be able to log on to my company VPN via Windows Sandbox.

Because of limitations in Windows Sandbox (at the time of this writing), there a few hardcodings in here, but if you follow those, or just change them, you're good to go.

## Get started

1. Clone the repo to "C:\virtualization" by using `git clone https://github.com/JohnyWS/cs-go-config.git sandbox`
   *The `sandbox` part in the end is important. That makes sure the full local path is correct.*
2. Add your rdp files to the ressources folder. Read the /ressources/suggestions.md for more info.
3. Add your company vpn installer exe to `/software` but named `company-vpn.exe`
4. Run `/company-sandbox-runner.wsb` and you're good to go (requires Windows Sandbox to be installed)