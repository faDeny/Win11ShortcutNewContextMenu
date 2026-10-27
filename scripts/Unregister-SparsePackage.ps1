# Unregister sparse package
# Run as Administrator

param(
    [string]$PackageName = "NewShortcutContextMenu"
)

Write-Host "Unregistering sparse package..." -ForegroundColor Cyan

Get-AppxPackage -Name $PackageName -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue

# Also try to unregister
$package = Get-AppxPackage | Where-Object { $_.Name -like "*NewShortcut*" }
if ($package) {
    Remove-AppxPackage -Package $package.PackageFullName
    Write-Host "Unregistered: $($package.PackageFullName)" -ForegroundColor Green
} else {
    Write-Host "Package not found or already unregistered" -ForegroundColor Yellow
}

pause
