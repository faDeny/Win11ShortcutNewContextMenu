@echo off
REM Build script for NewShortcutContextMenu
REM Requires Visual Studio Developer Command Prompt

echo Building NewShortcutContextMenu...

if not exist build mkdir build

REM Compile
cl /c /EHsc /std:c++17 /MD /I"C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\um" /I"C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\shared" /DUNICODE /D_UNICODE src\*.cpp /Fobuild\

if %ERRORLEVEL% NEQ 0 (
    echo Compilation failed
    exit /b 1
)

REM Link
link /DLL /DEF:src\NewShortcutContextMenu.def /OUT:build\NewShortcutContextMenu.dll build\*.obj /MACHINE:X64 /SUBSYSTEM:WINDOWS shlwapi.lib shell32.lib user32.lib ole32.lib oleaut32.lib uuid.lib runtimeobject.lib

if %ERRORLEVEL% NEQ 0 (
    echo Linking failed
    exit /b 1
)

echo Build complete: build\NewShortcutContextMenu.dll

REM Create package
if exist build\package rmdir /s /q build\package
mkdir build\package
copy build\NewShortcutContextMenu.dll build\package\
copy Package\AppxManifest.xml build\package\
copy Package\StoreLogo.png build\package\ 2>nul
copy Package\Square150x150Logo.png build\package\ 2>nul
copy Package\Square44x44Logo.png build\package\ 2>nul
copy Package\NewShortcutHost.exe build\package\ 2>nul

echo Package prepared in build\package\
pause
