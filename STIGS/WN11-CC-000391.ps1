<#
.SYNOPSIS
This PowerShell script disables Internet Explorer 11 as a standalone browser on Windows 11,
applies related policy-backed registry settings, refreshes Group Policy, and validates the configuration.

.NOTES
Author            : Felix Tafoya
LinkedIn          : linkedin.com/in/felixtafoya/
GitHub            : github.com/felixtafoya
Date Created      : 2026-03-17
Last Modified     : 2026-03-17
Version           : 1.3
CVEs              : N/A
Plugin IDs        : N/A
STIG-ID           : WN11-CC-000391

.TESTED ON
Date(s) Tested    : 2026-03-17
Tested By         : Felix Tafoya
Systems Tested    : Windows 11
PowerShell Ver.   : 5.1 / 7.x

.USAGE
Run this script in PowerShell as Administrator.

Example syntax:
PS C:\> .\WN11-CC-000391.ps1
#>

# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    exit 1
}

# Define registry path and values
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Internet Explorer\Main"

$settings = @{
    "DisableInternetExplorerApp" = 1
    "NotifyDisableIEOptions"     = 1
    "HideInternetExplorer"       = 1
}

Write-Host "Checking registry path..." -ForegroundColor Cyan

# Create registry path if it does not exist
if (-not (Test-Path $registryPath)) {
    try {
        New-Item -Path $registryPath -Force | Out-Null
        Write-Host "Created missing registry path: $registryPath" -ForegroundColor Yellow
    } catch {
        Write-Host "ERROR: Failed to create registry path." -ForegroundColor Red
        exit 1
    }
}

Write-Host "Applying IE disable policy..." -ForegroundColor Cyan

# Apply all required values
try {
    foreach ($name in $settings.Keys) {
        New-ItemProperty -Path $registryPath `
            -Name $name `
            -PropertyType DWord `
            -Value $settings[$name] `
            -Force | Out-Null
    }
} catch {
    Write-Host "ERROR: Failed to set one or more registry values." -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 1

Write-Host "Refreshing Group Policy..." -ForegroundColor Cyan

try {
    gpupdate /force | Out-Null
    Write-Host "SUCCESS: Group Policy refreshed." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to refresh Group Policy." -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 1

Write-Host "Validating..." -ForegroundColor Cyan

# Validate result safely
try {
    $result = Get-ItemProperty -Path $registryPath -ErrorAction Stop

    $allValid = $true

    foreach ($name in $settings.Keys) {
        if ($result.$name -ne $settings[$name]) {
            Write-Host "FAIL: Registry value '$name' is incorrect." -ForegroundColor Red
            $allValid = $false
        }
    }

    if (-not $allValid) {
        exit 1
    }

    Write-Host "SUCCESS: Internet Explorer 11 policy settings were applied successfully." -ForegroundColor Green
    Write-Host ""
    Write-Host "Current configuration:" -ForegroundColor Cyan
    $result | Select-Object DisableInternetExplorerApp, NotifyDisableIEOptions, HideInternetExplorer

    Write-Host ""
    Write-Host "IMPORTANT: Reboot required before rescanning." -ForegroundColor Yellow

} catch {
    Write-Host "FAIL: One or more registry values could not be validated." -ForegroundColor Red
    exit 1
}
