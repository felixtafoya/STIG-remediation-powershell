<#
.SYNOPSIS
Validates that the account lockout threshold is set to 3 or fewer invalid logon attempts on Windows 11.

.NOTES
Author            : Felix Tafoya
LinkedIn          : linkedin.com/in/felixtafoya/
GitHub            : github.com/felixtafoya
Date Created      : 2026-03-17
Last Modified     : 2026-03-17
Version           : 1.1
STIG-ID           : WN11-AC-000010

.TESTED ON
Windows 11 | PowerShell 5.1 / 7.x

.USAGE
Run in PowerShell:
PS C:\> .\WN11-AC-000010-Validate.ps1
#>

$result = net accounts
$thresholdLine = $result | Select-String "Lockout threshold"

if ($thresholdLine -match ":\s*3") {
    Write-Host "SUCCESS: Account lockout threshold is set to 3." -ForegroundColor Green
} else {
    Write-Host "FAIL: Account lockout threshold not set correctly." -ForegroundColor Red
}
