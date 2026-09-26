$ErrorActionPreference = 'Stop'
$taskRoot = $PSScriptRoot
$pythonPath = Join-Path $taskRoot '.venv/Scripts/pythonw.exe'
$scriptPath = Join-Path $taskRoot 'discover.py'
if (-not (Test-Path -LiteralPath $pythonPath)) { throw 'Run setup.ps1 first.' }
$action = New-ScheduledTaskAction -Execute $pythonPath -Argument ('"' + $scriptPath + '"') -WorkingDirectory $taskRoot
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1) -RepetitionInterval (New-TimeSpan -Minutes 15)
$principal = New-ScheduledTaskPrincipal -UserId ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name) -LogonType Interactive -RunLevel Limited
$settings = New-ScheduledTaskSettingsSet -MultipleInstances IgnoreNew -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 14)
Register-ScheduledTask -TaskName 'Glance Package Discovery' -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
Write-Host 'Discovery scheduled every 15 minutes while this Windows user is signed in.'
