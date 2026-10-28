#Requires -Version 5.1

# Self-elevate if not running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arguments = "-ExecutionPolicy Bypass -NoProfile -File `"$PSCommandPath`""
    Start-Process powershell -Verb RunAs -ArgumentList $arguments
    exit
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Enable-Sideloading {
    Write-Host "Checking sideloading/developer settings..." -ForegroundColor Yellow
    
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    
    $devLicense = Get-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
    if (-not $devLicense -or $devLicense.AllowDevelopmentWithoutDevLicense -ne 1) {
        New-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -PropertyType DWord -Force | Out-Null
        Write-Host "Enabled: AllowDevelopmentWithoutDevLicense" -ForegroundColor Green
    }
    
    $allowAll = Get-ItemProperty -Path $regPath -Name "AllowAllTrustedApps" -ErrorAction SilentlyContinue
    if (-not $allowAll -or $allowAll.AllowAllTrustedApps -ne 1) {
        New-ItemProperty -Path $regPath -Name "AllowAllTrustedApps" -Value 1 -PropertyType DWord -Force | Out-Null
        Write-Host "Enabled: AllowAllTrustedApps" -ForegroundColor Green
    }
    
    Write-Host "Sideloading settings applied." -ForegroundColor Green
    Write-Host ""
}

Clear-Host
Write-Host "Win11 Shortcut in Primary Context Menu" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Auto-enable sideloading for trusted apps
Enable-Sideloading

Write-Host "[1] Install" -ForegroundColor Green
Write-Host "[2] Uninstall" -ForegroundColor Yellow
Write-Host "[Q] Quit" -ForegroundColor Gray
Write-Host ""

$choice = Read-Host "Enter your choice"

switch ($choice.ToUpper()) {
    "1" {
        Write-Host "`nStarting installer..." -ForegroundColor Green
        & "$scriptRoot\Install.ps1"
        break
    }
    "2" {
        Write-Host "`nStarting uninstaller..." -ForegroundColor Yellow
        & "$scriptRoot\Uninstall.ps1"
        break
    }
    "Q" {
        exit
    }
    default {
        Write-Host "`nInvalid choice. Press any key to exit..." -ForegroundColor Red
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
}
