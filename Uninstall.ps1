#Requires -RunAsAdministrator

$ErrorActionPreference = "SilentlyContinue"

Write-Host "=== Win11 Shortcut in Primary Context Menu - Uninstaller ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Removing installation..." -ForegroundColor Yellow
$existing = Get-AppxPackage -Name "*NewShortcut*"
if ($existing) {
    $existing | Remove-AppxPackage
    Write-Host "Package removed." -ForegroundColor Green
} else {
    Write-Host "No installation found." -ForegroundColor Yellow
}

Write-Host "Restarting File Explorer..." -ForegroundColor Yellow
Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Start-Process explorer.exe
Write-Host "Done." -ForegroundColor Green

Write-Host ""
Write-Host "Uninstallation complete!" -ForegroundColor Green
Pause
