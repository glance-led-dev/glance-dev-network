param([string]$Email = '')
$ErrorActionPreference = 'Stop'
$taskRoot = $PSScriptRoot
if (-not (Test-Path -LiteralPath "$taskRoot/.venv/Scripts/python.exe")) {
    py -3.14 -m venv "$taskRoot/.venv"
    if ($LASTEXITCODE -ne 0) { throw 'Python environment setup failed.' }
}
& "$taskRoot/.venv/Scripts/python.exe" -m pip install -r "$taskRoot/requirements.txt"
if ($LASTEXITCODE -ne 0) { throw 'Dependency setup failed.' }
& "$taskRoot/.venv/Scripts/python.exe" "$taskRoot/discover.py" --setup --email $Email
if ($LASTEXITCODE -ne 0) { throw 'Gmail setup did not complete.' }
