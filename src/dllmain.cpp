#include "pch.h"
#include "NewShortcutCommand.h"

using namespace Microsoft::WRL;

CoCreatableClass(NewShortcutCommand);

#if !defined(__WRL_CLASSIC_COM__)
STDAPI DllGetActivationFactory(_In_ HSTRING activatibleClassId, _Out_ IActivationFactory** factory)
{
    return Module<InProc>::GetModule().GetActivationFactory(activatibleClassId, factory);
}
#endif

STDAPI DllGetClassObject(REFCLSID rclsid, REFIID riid, _Out_ LPVOID* ppv)
{
    return Module<InProc>::GetModule().GetClassObject(rclsid, riid, ppv);
}

STDAPI DllCanUnloadNow()
{
    return Module<InProc>::GetModule().GetObjectCount() == 0 ? S_OK : S_FALSE;
}

STDAPI DllRegisterServer()
{
    return S_OK;
}

STDAPI DllUnregisterServer()
{
    return S_OK;
}

BOOL APIENTRY DllMain(HMODULE hModule,
    DWORD  ul_reason_for_call,
    LPVOID lpReserved
)
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
        DisableThreadLibraryCalls(hModule);
        break;
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}
