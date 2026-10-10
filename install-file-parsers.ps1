param([string]$PythonExecutable = 'python')
$ErrorActionPreference = 'Stop'
$runtime = Join-Path $PSScriptRoot '.runtime'
$venv = Join-Path $runtime 'file-python'
$python = Join-Path $venv 'Scripts\python.exe'
if (-not (Test-Path -LiteralPath $python)) {
    & $PythonExecutable -m venv $venv
    if ($LASTEXITCODE -ne 0) { throw 'Python 3.10+ is required; pass -PythonExecutable with its path.' }
}
& $python -m pip install --disable-pip-version-check --no-cache-dir -r (Join-Path $PSScriptRoot 'file-parser-requirements.txt')
if ($LASTEXITCODE -ne 0) { throw 'Optional file parser installation failed.' }
Write-Host "File parser Python: $python"
Write-Host 'Pass this path to configure-file-access.ps1 -PythonExecutable to enable document parsing.'
