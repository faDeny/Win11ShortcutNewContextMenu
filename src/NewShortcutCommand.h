#pragma once

#include <windows.h>
#include <shobjidl_core.h>
#include <shlwapi.h>
#include <wrl/module.h>
#include <wrl/implements.h>

using namespace Microsoft::WRL;

class __declspec(uuid("A7F9B3E2-8D4C-4A1E-9F2B-6C8E1A3D5F7B"))
NewShortcutCommand : public RuntimeClass<RuntimeClassFlags<ClassicCom>, IExplorerCommand>
{
public:
    NewShortcutCommand() = default;

    // IExplorerCommand
    IFACEMETHODIMP GetTitle(IShellItemArray* psiItemArray, LPWSTR* ppszName) override;
    IFACEMETHODIMP GetIcon(IShellItemArray* psiItemArray, LPWSTR* ppszIcon) override;
    IFACEMETHODIMP GetToolTip(IShellItemArray* psiItemArray, LPWSTR* ppszInfotip) override;
    IFACEMETHODIMP GetCanonicalName(GUID* pguidCommandName) override;
    IFACEMETHODIMP GetState(IShellItemArray* psiItemArray, BOOL fOkToBeSlow, EXPCMDSTATE* pCmdState) override;
    IFACEMETHODIMP Invoke(IShellItemArray* psiItemArray, IBindCtx* pbc) override;
    IFACEMETHODIMP GetFlags(EXPCMDFLAGS* pFlags) override;
    IFACEMETHODIMP EnumSubCommands(IEnumExplorerCommand** ppEnum) override;

private:
    HRESULT GetTargetFolder(IShellItemArray* psiItemArray, PWSTR pszPath, DWORD cchPath);
};
