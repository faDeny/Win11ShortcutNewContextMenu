# New Shortcut Context Menu Prototype
# For adding "Create Shortcut" wizard to Windows 11 primary context menu

## Overview
This prototype adds a "Shortcut" command directly to the Windows 11 primary context menu (not under "Show more options") using:
- `IExplorerCommand` COM interface
- Sparse MSIX package for app identity
- `rundll32 appwiz.cpl,NewLinkHere` to invoke the actual Create Shortcut wizard

## Requirements
- Windows 11 (build 22000+)
- Visual Studio 2022 with C++ workload
- Windows 11 SDK
- Administrator privileges for registration

## Build Instructions

### 1. Build the DLL
Open "Developer Command Prompt for VS 2022" in this directory and run:
```batch
scripts\build.bat
```

Or manually:
```batch
cl /c /EHsc /std:c++17 /MD src\*.cpp /Fobuild\
link /DLL /DEF:src\NewShortcutContextMenu.def /OUT:build\NewShortcutContextMenu.dll build\*.obj shlwapi.lib shell32.lib user32.lib ole32.lib oleaut32.lib uuid.lib runtimeobject.lib
```

### 2. Create minimal host executable (optional)
The manifest references `NewShortcutHost.exe` but for sparse packages with external content, we can create a dummy exe or use an existing one.

### 3. Register the sparse package
Run PowerShell as Administrator:
```powershell
.\scripts\Register-SparsePackage.ps1
```

### 4. Test
Right-click on Desktop, or in a folder background. You should see "Shortcut" in the primary context menu. Clicking it will open the Create Shortcut wizard.

### 5. Unregister
```powershell
.\scripts\Unregister-SparsePackage.ps1
```

## Notes
- This uses the same wizard as "New > Shortcut" via `appwiz.cpl,NewLinkHere`
- Registration requires package identity via sparse MSIX
- The CLSID is `A7F9B3E2-8D4C-4A1E-9F2B-6C8E1A3D5F7B` - change for your own use
- Publisher in manifest needs to match your certificate if signing
- For testing without signing, some builds allow unsigned sparse packages in developer mode

## Troubleshooting
- If it doesn't appear in primary menu, check Settings > Privacy & Security > For developers (Developer Mode)
- Use "Show more options" to see if it appears there (classic menu)
- Check Event Viewer for COM/shell errors
- Restart Explorer after registration: `taskkill /f /im explorer.exe && start explorer.exe`

## References
- [Integrate packaged app with File Explorer](https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/integrate-packaged-app-with-file-explorer)
- [nppShell](https://github.com/notepad-plus-plus/nppShell)
- [IExplorerCommand](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-iexplorercommand)
