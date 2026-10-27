# Win11 Shortcut in Primary Context Menu

Add "Shortcut" directly to the Windows 11 primary right-click context menu (Desktop and folder backgrounds). This launches the same "Create Shortcut" wizard as `New > Shortcut`.

**Verified on Windows 11 26H2 (build 26300). Results may vary on other builds.**

## What's in this repo

This repository contains the **prototype/source** for the `NewShortcutContextMenu` implementation:

- `src/` – C++ `IExplorerCommand` COM handler (`NewShortcutCommand`)
- `Package/` – Sparse MSIX manifest, files needed for registration
- `scripts/` – Helper scripts for building/registering
- `README.md` – This file

This is the custom implementation that makes the primary-menu "Shortcut" entry possible on modern Windows 11. It uses package identity (sparse MSIX) rather than a legacy registry-only tweak.

## For end users (easiest way)

**If you just want to install it and use it:**

1. Go to the [Releases](https://github.com/faDeny/Win11ShortcutNewContextMenu/releases) page (if available) and download the latest release ZIP, or download this repo as ZIP from the green `Code > Download ZIP` button.
2. Extract to a **fixed location** (e.g. `C:\Tools\Win11ShortcutNewContextMenu\`). Do **not** move it after installation.
3. Open PowerShell as Administrator in that extracted folder.
4. Run the installer script (see below). It will trust the certificate, register the package, and restart Explorer.
5. Done. Right-click Desktop or folder background → you'll see `Shortcut` in the primary menu.

### Quick install (using this repo)

From an elevated PowerShell in the extracted folder:

```powershell
# Allow script execution for this session
Set-ExecutionPolicy -Scope Process Bypass -Force

# Run installer (if present) OR follow manual steps
.\Install.ps1
```

If `Install.ps1` isn't present yet, use the manual steps in the sections below.

## Manual install (detailed)

### 1) Trust the certificate
```powershell
$root = (Get-Location).Path
$cert = New-SelfSignedCertificate -Type Custom -Subject "CN=NewShortcutTest" -KeyUsage DigitalSignature -FriendlyName "NewShortcutTest" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3")
$pwd = ConvertTo-SecureString -String "test123" -Force -AsPlainText
Export-PfxCertificate -Cert $cert -FilePath "$root\NewShortcutTest.pfx" -Password $pwd | Out-Null
Import-PfxCertificate -FilePath "$root\NewShortcutTest.pfx" -CertStoreLocation Cert:\LocalMachine\TrustedPeople -Password $pwd | Out-Null
```

### 2) Register
```powershell
Get-AppxPackage -Name "*NewShortcut*" | Remove-AppxPackage -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Add-AppxPackage -ExternalLocation ".\Package" -Path ".\Package\AppxManifest.xml" -Register
```

### 3) Restart Explorer
```powershell
Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Start-Process explorer.exe
```

## Uninstall / Remove

```powershell
Get-AppxPackage -Name "*NewShortcut*" | Remove-AppxPackage -ErrorAction SilentlyContinue
Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Start-Process explorer.exe
```

You can delete the folder after unregistering if you want.

## Notes

- This requires Windows 11 (modern context menu). On older builds it won't appear.
- The DLL is signed with a test certificate included for convenience. You may need to trust it.
- Keep the extracted folder in place - sparse package registration references it via `-ExternalLocation`.
- This adds the entry to the **primary** context menu, not under "Show more options".

## For developers

If you want to rebuild from source, see `SuperUser_Tutorial.MD` or look in `src/` and `scripts/`.
