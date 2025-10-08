Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$EnvName = 'py312'
$PyVer   = '3.12'

function Find-CondaExe {
    # 1) If CONDA_EXE env var is set (usually points to conda.exe), use it
    if ($env:CONDA_EXE -and (Test-Path $env:CONDA_EXE)) { 
        return $env:CONDA_EXE 
    }

    # 2) Prefer real executables over functions/aliases
    $app = Get-Command conda.exe -ErrorAction SilentlyContinue
    if ($app -and $app.CommandType -eq 'Application') { return $app.Path }

    $bat = Get-Command conda.bat -ErrorAction SilentlyContinue
    if ($bat -and $bat.CommandType -eq 'Application') { return $bat.Path }

    $maybeApp = Get-Command conda -ErrorAction SilentlyContinue
    if ($maybeApp -and $maybeApp.CommandType -eq 'Application' -and $maybeApp.Path) { 
        return $maybeApp.Path 
    }

    # 3) Fallback to common install locations
    $candidates = @(
        "$env:USERPROFILE\miniconda3\condabin\conda.bat",
        "$env:USERPROFILE\miniconda3\Scripts\conda.exe",
        "$env:USERPROFILE\Anaconda3\condabin\conda.bat",
        "$env:USERPROFILE\Anaconda3\Scripts\conda.exe",
        "$env:ProgramData\miniconda3\condabin\conda.bat",
        "$env:ProgramData\miniconda3\Scripts\conda.exe",
        "$env:ProgramData\Anaconda3\condabin\conda.bat",
        "$env:ProgramData\Anaconda3\Scripts\conda.exe"
    )
    foreach ($c in $candidates) { if (Test-Path $c) { return $c } }

    throw 'conda not found. Please install Miniconda/Anaconda and ensure it is on PATH.'
}

$Conda = Find-CondaExe
Write-Host ">>> Using conda: $Conda"

Write-Host ">>> Step 1: create conda env (Python $PyVer): $EnvName"
& $Conda create -y -n $EnvName "python=$PyVer" | Out-Null

Write-Host '>>> Step 2: create .venv in current folder'
& $Conda run -n $EnvName python -m venv .venv

$VenvPython = '.\.venv\Scripts\python.exe'
$VenvPip    = '.\.venv\Scripts\pip.exe'

Write-Host '>>> Step 3: upgrade pip/wheel'
& $VenvPython -m pip install -U pip wheel

Write-Host '>>> Step 4: install from requirements.txt if present'
if (Test-Path 'requirements.txt') {
    & $VenvPip install -r requirements.txt
} else {
    Write-Warning 'requirements.txt not found. Skipping dependency install.'
}

Write-Host ''
Write-Host 'Done.'
Write-Host 'Activate venv with: .\.venv\Scripts\activate'
