<#
.SYNOPSIS
    This PowerShell script ensures anonymous enumeration is restricted on Windows 11.

.NOTES
    Author        : Felix Tafoya
    LinkedIn      : linkedin.com/in/felixtafoya/
    GitHub        : github.com/felixtafoya
    Date Created  : 2026-03-16
    Last Modified : 2026-03-16
    Version       : 1.0
    CVEs          : N/A
    Plugin IDs    : N/A
    STIG-ID       : WN11-CC-000005

.TESTED ON
    Date(s) Tested :
    Tested By      :
    Systems Tested :
    PowerShell Ver. :

.USAGE
    Run this script in PowerShell as Administrator.

    Example syntax:
    PS C:\> .\WN11-CC-000005.ps1
#>

# Define the registry path and value
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa"
$valueName = "RestrictAnonymous"
$valueData = 1  # Restrict anonymous access

# Check if the registry path exists, if not create it
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the registry value
New-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -PropertyType DWord -Force | Out-Null

# Validate the setting
$result = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

if ($result.$valueName -eq $valueData) {
    Write-Host "SUCCESS: Registry value '$valueName' is set to '$valueData' at '$registryPath'."
} else {
    Write-Host "FAIL: Registry value '$valueName' is not set correctly."
}
