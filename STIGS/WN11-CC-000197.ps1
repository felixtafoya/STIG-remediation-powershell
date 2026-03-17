<#
.SYNOPSIS
This PowerShell script ensures Microsoft consumer experiences are turned off on Windows 11.

.NOTES
Author            : Felix Tafoya
LinkedIn          : linkedin.com/in/felixtafoya/
GitHub            : github.com/felixtafoya
Date Created      : 2026-03-17
Last Modified     : 2026-03-17
Version           : 1.1
CVEs              : N/A
Plugin IDs        : N/A
STIG-ID           : WN11-CC-000197

.TESTED ON
Date(s) Tested    : 2026-03-17
Tested By         : Felix Tafoya
Systems Tested    : Windows 11
PowerShell Ver.   : 5.1 / 7.x

.USAGE
Run this script in PowerShell as Administrator.

Example syntax:
PS C:\> .\WN11-CC-000197.ps1
#>

# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "ERROR: This script must be run as Administrator." -ForegroundColor Red
    exit 1
}

# Define registry path and value
$registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
$valueName    = "DisableWindowsConsumerFeatures"
$valueData    = 1

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

Write-Host "Applying STIG setting..." -ForegroundColor Cyan

# Create value if missing, then set it
try {
    if ($null -eq (Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue)) {
        New-ItemProperty -Path $registryPath `
            -Name $valueName `
            -PropertyType DWord `
            -Value $valueData `
            -Force | Out-Null
    } else {
        Set-ItemProperty -Path $registryPath `
            -Name $valueName `
            -Value $valueData
    }
} catch {
    Write-Host "ERROR: Failed to set registry value." -ForegroundColor Red
    exit 1
}

Start-Sleep -Seconds 1

Write-Host "Validating setting..." -ForegroundColor Cyan

# Validate result safely
try {
    $result = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction Stop

    if ($result.$valueName -eq $valueData) {
        Write-Host "SUCCESS: Registry value '$valueName' is set to '$valueData' at '$registryPath'." -ForegroundColor Green
    } else {
        Write-Host "FAIL: Registry value '$valueName' is incorrect." -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "Current configuration:" -ForegroundColor Cyan
    $result | Select-Object $valueName

} catch {
    Write-Host "FAIL: Registry value '$valueName' not found." -ForegroundColor Red
    exit 1
}
