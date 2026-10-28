#Requires -RunAsAdministrator

param(
    [string]$InstallPath = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

Write-Host "=== Win11 Shortcut in Primary Context Menu - Installer ===" -ForegroundColor Cyan
Write-Host ""

# Enable sideloading/trusted apps just in case
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}
New-ItemProperty -Path $regPath -Name "AllowDevelopmentWithoutDevLicense" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $regPath -Name "AllowAllTrustedApps" -Value 1 -PropertyType DWord -Force | Out-Null

# Check if in correct location
$packagePath = Join-Path $InstallPath "Package"
$manifestPath = Join-Path $packagePath "AppxManifest.xml"

if (-not (Test-Path $manifestPath)) {
    Write-Host "Error: Package\AppxManifest.xml not found!" -ForegroundColor Red
    Write-Host "Please run this script from the extracted repository root." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

# 1. Trust certificate if not already trusted
Write-Host "[1/4] Checking certificate..." -ForegroundColor Yellow
$certSubject = "CN=NewShortcutTest"
$trustedCert = Get-ChildItem Cert:\LocalMachine\TrustedPeople | Where-Object { $_.Subject -eq $certSubject }

if (-not $trustedCert) {
    Write-Host "Trusting certificate..." -ForegroundColor Yellow
    $pfxPath = Join-Path $InstallPath "NewShortcutTest.pfx"
    if (-not (Test-Path $pfxPath)) {
        $pfxPath = Join-Path $packagePath "NewShortcutTest.pfx"
    }
    if (-not (Test-Path $pfxPath)) {
        $cert = New-SelfSignedCertificate -Type Custom -Subject $certSubject -KeyUsage DigitalSignature -FriendlyName "NewShortcutTest" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3")
        $pwd = ConvertTo-SecureString -String "test123" -Force -AsPlainText
        Export-PfxCertificate -Cert $cert -FilePath (Join-Path $InstallPath "NewShortcutTest.pfx") -Password $pwd | Out-Null
        $pfxPath = Join-Path $InstallPath "NewShortcutTest.pfx"
    }
    
    $pwd = ConvertTo-SecureString -String "test123" -Force -AsPlainText
    Import-PfxCertificate -FilePath $pfxPath -CertStoreLocation Cert:\LocalMachine\TrustedPeople -Password $pwd | Out-Null
    Write-Host "Certificate trusted." -ForegroundColor Green
} else {
    Write-Host "Certificate already trusted." -ForegroundColor Green
}

# 2. Remove existing registration if any
Write-Host "[2/4] Removing old installation if exists..." -ForegroundColor Yellow
$existing = Get-AppxPackage -Name "*NewShortcut*" -ErrorAction SilentlyContinue
if ($existing) {
    $existing | Remove-AppxPackage -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Write-Host "Old installation removed." -ForegroundColor Green
} else {
    Write-Host "No existing installation found." -ForegroundColor Green
}

# 3. Register package
Write-Host "[3/4] Registering package..." -ForegroundColor Yellow
try {
    Add-AppxPackage -ExternalLocation $packagePath -Path $manifestPath -Register -ErrorAction Stop
    Write-Host "Package registered successfully." -ForegroundColor Green
} catch {
    Write-Host "Error during registration: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "- Sideloading has been enabled by this script. If it still fails, go to Settings > Privacy & Security > For developers and set 'Developer Mode' to On." -ForegroundColor Yellow
    Write-Host "- Make sure the certificate is trusted in Local Machine > Trusted People" -ForegroundColor Yellow
    Write-Host "- Close all File Explorer windows" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# 4. Restart Explorer
Write-Host "[4/4] Restarting File Explorer..." -ForegroundColor Yellow
Get-Process explorer -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 2
Start-Process explorer.exe
Write-Host "Done." -ForegroundColor Green

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Right-click on Desktop or folder background to see 'Shortcut' in the primary menu." -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to exit"
