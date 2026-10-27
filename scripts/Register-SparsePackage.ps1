# Register sparse package for testing (unpackaged Win32 app)
# Run as Administrator

param(
    [string]$PackagePath = "$PSScriptRoot\..\Package",
    [string]$ExternalLocation = "$PSScriptRoot\..\Package"
)

Write-Host "Registering sparse package..." -ForegroundColor Cyan
Write-Host "Package: $PackagePath" -ForegroundColor Gray
Write-Host "External Location: $ExternalLocation" -ForegroundColor Gray

# Add-AppxPackage with external location for sparse package
Add-AppxPackage -ExternalLocation $ExternalLocation -Path (Join-Path $PackagePath "AppxManifest.xml") -Register

if ($LASTEXITCODE -eq 0) {
    Write-Host "Registration successful!" -ForegroundColor Green
    Write-Host "Right-click in File Explorer to see 'Shortcut' in the context menu" -ForegroundColor Yellow
} else {
    Write-Host "Registration failed. Exit code: $LASTEXITCODE" -ForegroundColor Red
}

pause
