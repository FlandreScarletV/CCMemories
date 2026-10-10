param(
    [string[]]$AllowedRoots,
    [string]$PythonExecutable,
    [switch]$Disable
)
$ErrorActionPreference = 'Stop'
$runtime = Join-Path $PSScriptRoot '.runtime'
$roots = @()
if (-not $Disable) {
    if (-not $AllowedRoots -or $AllowedRoots.Count -eq 0) { throw 'Specify -AllowedRoots, or use -Disable.' }
    foreach ($item in $AllowedRoots) {
        if (-not [IO.Path]::IsPathRooted($item) -or $item.StartsWith('\\')) { throw 'Use absolute local directory paths.' }
        $resolved = Get-Item -LiteralPath $item
        if (-not $resolved.PSIsContainer) { throw "Not a directory: $item" }
        $roots += $resolved.FullName
    }
}
if ($PythonExecutable -and -not (Get-Command $PythonExecutable -ErrorAction SilentlyContinue)) {
    throw 'Python executable was not found.'
}
New-Item -ItemType Directory -Path $runtime -Force | Out-Null
$settings = @{ allowedRoots = @($roots) }
if ($PythonExecutable) { $settings.pythonExecutable = $PythonExecutable }
$path = Join-Path $runtime 'local-files.json'
$utf8 = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText($path, ($settings | ConvertTo-Json -Depth 3), $utf8)
Write-Host "Read-only file access configured: $path"
Write-Host 'Only these roots are allowed; credential and runtime paths are blocked.'
