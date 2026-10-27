#include "pch.h"
#include "NewShortcutCommand.h"

#include <shlobj_core.h>
#include <propkey.h>
#include <shellapi.h>
#include <string>

extern HINSTANCE g_hInst;

HRESULT NewShortcutCommand::GetTargetFolder(IShellItemArray* psiItemArray, PWSTR pszPath, DWORD cchPath)
{
    if (!psiItemArray)
    {
        PWSTR pszDesktop = nullptr;
        if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_Desktop, 0, nullptr, &pszDesktop)))
        {
            wcscpy_s(pszPath, cchPath, pszDesktop);
            CoTaskMemFree(pszDesktop);
            return S_OK;
        }
        return E_FAIL;
    }

    DWORD count = 0;
    if (FAILED(psiItemArray->GetCount(&count)))
    {
        PWSTR pszDesktop = nullptr;
        if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_Desktop, 0, nullptr, &pszDesktop)))
        {
            wcscpy_s(pszPath, cchPath, pszDesktop);
            CoTaskMemFree(pszDesktop);
            return S_OK;
        }
        return E_FAIL;
    }

    if (count == 0)
    {
        PWSTR pszDesktop = nullptr;
        if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_Desktop, 0, nullptr, &pszDesktop)))
        {
            wcscpy_s(pszPath, cchPath, pszDesktop);
            CoTaskMemFree(pszDesktop);
            return S_OK;
        }
        return E_FAIL;
    }

    ComPtr<IShellItem> psi;
    if (FAILED(psiItemArray->GetItemAt(0, &psi)))
    {
        PWSTR pszDesktop = nullptr;
        if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_Desktop, 0, nullptr, &pszDesktop)))
        {
            wcscpy_s(pszPath, cchPath, pszDesktop);
            CoTaskMemFree(pszDesktop);
            return S_OK;
        }
        return E_FAIL;
    }

    SFGAOF attrs = 0;
    psi->GetAttributes(SFGAO_FOLDER | SFGAO_FILESYSTEM, &attrs);
    if (attrs & SFGAO_FOLDER)
    {
        PWSTR pszName = nullptr;
        if (SUCCEEDED(psi->GetDisplayName(SIGDN_FILESYSPATH, &pszName)))
        {
            wcscpy_s(pszPath, cchPath, pszName);
            CoTaskMemFree(pszName);
            return S_OK;
        }
    }

    ComPtr<IShellItem> psiParent;
    if (SUCCEEDED(psi->GetParent(&psiParent)))
    {
        PWSTR pszName = nullptr;
        if (SUCCEEDED(psiParent->GetDisplayName(SIGDN_FILESYSPATH, &pszName)))
        {
            wcscpy_s(pszPath, cchPath, pszName);
            CoTaskMemFree(pszName);
            return S_OK;
        }
    }

    PWSTR pszDesktop = nullptr;
    if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_Desktop, 0, nullptr, &pszDesktop)))
    {
        wcscpy_s(pszPath, cchPath, pszDesktop);
        CoTaskMemFree(pszDesktop);
        return S_OK;
    }

    return E_FAIL;
}

IFACEMETHODIMP NewShortcutCommand::GetTitle(IShellItemArray* /*psiItemArray*/, LPWSTR* ppszName)
{
    return SHStrDupW(L"Shortcut", ppszName);
}

IFACEMETHODIMP NewShortcutCommand::GetIcon(IShellItemArray* /*psiItemArray*/, LPWSTR* ppszIcon)
{
    // Use shell32 shortcut icon
    return SHStrDupW(L"shell32.dll,-16769", ppszIcon);
}

IFACEMETHODIMP NewShortcutCommand::GetToolTip(IShellItemArray* /*psiItemArray*/, LPWSTR* ppszInfotip)
{
    *ppszInfotip = nullptr;
    return E_NOTIMPL;
}

IFACEMETHODIMP NewShortcutCommand::GetCanonicalName(GUID* pguidCommandName)
{
    *pguidCommandName = GUID_NULL;
    return S_OK;
}

IFACEMETHODIMP NewShortcutCommand::GetState(IShellItemArray* /*psiItemArray*/, BOOL /*fOkToBeSlow*/, EXPCMDSTATE* pCmdState)
{
    *pCmdState = ECS_ENABLED;
    return S_OK;
}

IFACEMETHODIMP NewShortcutCommand::Invoke(IShellItemArray* psiItemArray, IBindCtx* /*pbc*/)
{
    WCHAR szTarget[MAX_PATH];
    if (FAILED(GetTargetFolder(psiItemArray, szTarget, MAX_PATH)))
    {
        PWSTR pszDesktop = nullptr;
        if (SUCCEEDED(SHGetKnownFolderPath(FOLDERID_Desktop, 0, nullptr, &pszDesktop)))
        {
            wcscpy_s(szTarget, MAX_PATH, pszDesktop);
            CoTaskMemFree(pszDesktop);
        }
        else
        {
            return E_FAIL;
        }
    }

    WCHAR szParams[2048];
    swprintf_s(szParams, 2048, L"appwiz.cpl,NewLinkHere %s", szTarget);

    SHELLEXECUTEINFOW sei = { 0 };
    sei.cbSize = sizeof(sei);
    sei.fMask = SEE_MASK_DEFAULT;
    sei.lpFile = L"rundll32.exe";
    sei.lpParameters = szParams;
    sei.lpDirectory = szTarget;
    sei.nShow = SW_SHOWNORMAL;

    ShellExecuteExW(&sei);
    return S_OK;
}

IFACEMETHODIMP NewShortcutCommand::GetFlags(EXPCMDFLAGS* pFlags)
{
    *pFlags = ECF_DEFAULT;
    return S_OK;
}

IFACEMETHODIMP NewShortcutCommand::EnumSubCommands(IEnumExplorerCommand** ppEnum)
{
    if (ppEnum) *ppEnum = nullptr;
    return E_NOTIMPL;
}
