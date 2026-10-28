# Win11 Shortcut in Primary Context Menu
<img width="277" height="458" alt="Shortcut in Windows 11 primary Context menu" src="https://github.com/user-attachments/assets/364a27b7-290d-4c3d-8ac0-2ffa07d7a56c" />

Adds a `Shortcut` entry directly to the Windows 11 primary context menu (Desktop and folder backgrounds) that opens the exact same "Create Shortcut" wizard as `New > Shortcut`.

Verified on Windows 11 26H2 (build 26300). Results may vary on other builds.

## For users (quick install)

1. Download from [Releases](https://github.com/faDeny/Win11ShortcutNewContextMenu/releases) or `Code > Download ZIP` from this repo.
2. Extract to a fixed location (e.g. `C:\Tools\Win11ShortcutNewContextMenu\`). **Do not move it after install.**
3. Right-click `Menu.ps1` → `Run with PowerShell`. Accept the UAC prompt.
4. Type `1` and press Enter to install.
5. Done. `Shortcut` will appear in the primary right-click menu.

To remove it, run `Uninstall.ps1` as Administrator. You can delete the folder after uninstalling.

## What's in this repo

- `Menu.ps1` – Simple menu that auto-elevates and lets you choose Install or Uninstall
- `Install.ps1` / `Uninstall.ps1` – Install/uninstall scripts used by the menu (can also be run directly in an elevated terminal)
- `Package/` – Sparse MSIX files used for registration (`AppxManifest.xml`, signed `NewShortcutContextMenu.dll`, `NewShortcutHost.exe`, icons)
- `src/` – C++ source code for the `IExplorerCommand` COM handler
- `scripts/` – Helper scripts for building and manual registration

## How this works (overview)

Windows 11's modern primary context menu doesn't show most classic `ShellNew` entries. To add a custom command there, this project uses:

- **`IExplorerCommand`** – The modern COM interface for File Explorer context menu entries.
- **Sparse MSIX with package identity** – Allows an unpackaged Win32 DLL to be loaded by Explorer in the primary menu.
- **Built-in shortcut wizard** – `Invoke()` calls `rundll32.exe shell32.dll,SHCreateLocalServerRunDll {D969A300-E7FF-11d0-A93B-00A0C90F2719}` with the target folder, launching the exact same wizard as `New > Shortcut`.
- **Registration scopes** – Declared for `Directory\Background` and `Directory` so it shows on the Desktop and inside folders.

## Recreate or customize this for your own app

You can use this same approach to add other apps (like `mspaint.exe`) to the primary menu. This is the "custom" part of the repo.

### Steps

1. **Clone/copy this repo** as a starting point.
2. **Change what it launches.** Edit `src/NewShortcutCommand.cpp` in `Invoke()`. Right now it calls `rundll32.exe shell32.dll,SHCreateLocalServerRunDll {D969A300-E7FF-11d0-A93B-00A0C90F2719}` to open the built-in "Create Shortcut" wizard. Replace that call with your own code using `ShellExecuteW` or `CreateProcessW` to launch your target (e.g. `C:\Windows\System32\mspaint.exe`). You can pass the current folder from the `IShellItemArray` if needed.
3. **Give it a unique identity.** Update `Package/AppxManifest.xml`:
   - Change `Identity Name` and `Publisher` to unique values
   - Change the COM CLSID for your command (`comServer/Class/@Id`)
   - Keep the same sparse MSIX structure
4. **Update source CLSIDs/strings.** Change the command CLSID in `src/NewShortcutCommand.cpp`/headers to match your manifest.
5. **Build the DLL.** Use `scripts/build.bat` or compile manually with Visual Studio. Copy the built DLL to `Package/`.
6. **Create and trust a certificate.** Generate your own self-signed cert and trust it in `Cert:\LocalMachine\TrustedPeople`. Update `Publisher` in the manifest to match.
7. **Sign the DLL.** Sign `Package/NewShortcutContextMenu.dll` with `signtool.exe` using your certificate.
8. **Register.** Run `Install.ps1` (update it to use your cert if needed) or `Add-AppxPackage -ExternalLocation ".\Package" -Path ".\Package\AppxManifest.xml" -Register`.
9. **Test.** Restart Explorer and check the primary context menu.

### Tips

- **Don't reuse CLSIDs** if you publish or distribute this.
- **Keep a fixed path.** Sparse packages reference files by the external location you registered.
- **`NewShortcutHost.exe` is required** by the MSIX schema but is never launched. A copy of `notepad.exe` works fine.
- **For distribution**, you'd want a proper code signing certificate instead of a self-signed test cert.

## Example: replace "Shortcut" with "New Text File" and "Paint"

You can't just show two different entries with this single COM handler as-is. Each registered `IExplorerCommand` is one entry. To have two separate entries ("New Text File" and "Paint") you'd need two different COM commands (different CLSIDs), each with its own registration in `AppxManifest.xml`, and each pointing to its own handler.

But for the sake of showing how to change what `Invoke()` does, here's a minimal example of replacing the wizard call with either action:

### 1) Create an empty .txt file in the current folder

In `src/NewShortcutCommand.cpp` inside `Invoke()` (replace the `rundll32` call):

```cpp
// Get target folder from IShellItemArray
// ...existing code to get folder path...

WCHAR path[MAX_PATH];
PathCombineW(path, folderPath, L"New Text Document.txt");
HANDLE h = CreateFileW(path, GENERIC_WRITE, 0, NULL, CREATE_NEW, FILE_ATTRIBUTE_NORMAL, NULL);
if (h != INVALID_HANDLE_VALUE) CloseHandle(h);
// optionally: SHChangeNotify or just leave it
```

You may need to include `<windows.h>`, `<shlwapi.h>`. If the file already exists, `CREATE_NEW` will fail - you can use `CREATE_ALWAYS` or increment the name instead.

### 2) Start Microsoft Paint

```cpp
// Get target folder from IShellItemArray if you want to pass working dir
ShellExecuteW(NULL, L"open", L"mspaint.exe", NULL, folderPath, SW_SHOWNORMAL);
```

### How to make both appear

1. Duplicate the command registration: add a second `com:Class` with a new GUID and a second `desktop4:FileExplorerContextMenus` entry (or just add another `ItemType`/handler) in `Package/AppxManifest.xml`. 
2. Create a second class/handler or branch in code based on the command, but easier to have two separate DLLs/handlers with different CLSIDs.
3. Give each its own unique `Identity Name`, `Publisher`, and CLSID. Build, sign, and register as usual.

The flow (sparse MSIX + `IExplorerCommand` + registration) is the same. The key is one handler = one menu entry.

## Manual build/register (reference)

If you don't want to use `Install.ps1`, see the scripts in `scripts/` or the commands in the original tutorial. The flow is: build → sign → trust cert → register with `Add-AppxPackage -ExternalLocation ... -Register` → restart Explorer.

## References

- [Integrate a packaged app with File Explorer](https://learn.microsoft.com/en-us/windows/apps/desktop/modernize/integrate-packaged-app-with-file-explorer)
- [IExplorerCommand (Win32 API)](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-iexplorercommand)
- [nppShell](https://github.com/notepad-plus-plus/nppShell) - Great reference for this exact pattern

## License

Provided as-is for educational and testing purposes.
