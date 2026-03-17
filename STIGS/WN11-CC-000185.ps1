<#
.SYNOPSIS
This PowerShell script disables AutoRun on Windows 11.

.NOTES
Author            : Felix Tafoya
LinkedIn          : linkedin.com/in/felixtafoya/
GitHub            : github.com/felixtafoya
Date Created      : 2026-03-17
Last Modified     : 2026-03-17
Version           : 1.0
CVEs              : N/A
Plugin IDs        : N/A
STIG-ID           : WN11-CC-000185

.TESTED ON
Date(s) Tested    :
Tested By         :
Systems Tested    :
PowerShell Ver.   :

.USAGE
Run this script in PowerShell as Administrator.

Example syntax:
PS C:\> .\WN11-CC-000185.ps1
#>

$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$valueName = "NoAutorun"
$valueData = 1

if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

New-ItemProperty -Path $registryPath -Name $valueName -Value $valueData -PropertyType DWord -Force | Out-Null

$result = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

if ($result.$valueName -eq $valueData) {
    Write-Host "SUCCESS"
} else {
    Write-Host "FAIL"
}
