@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

set "CONDA_ENV_NAME=py312"
set "PY_VER=3.12"

echo ======================================================
echo  Step 1: Create Conda environment (Python %PY_VER%)
echo ======================================================
conda create -y -n %CONDA_ENV_NAME% python=%PY_VER%
if errorlevel 1 (
    echo [ERROR] Failed to create conda environment.
    exit /b 1
)

echo ======================================================
echo  Step 2: Activate Conda environment
echo ======================================================
call conda activate %CONDA_ENV_NAME%
if errorlevel 1 (
    echo [ERROR] Failed to activate conda environment.
    exit /b 1
)

echo ======================================================
echo  Step 3: Create local virtual environment (.venv)
echo ======================================================
python -m venv .venv
if errorlevel 1 (
    echo [ERROR] Failed to create virtual environment.
    exit /b 1
)

echo ======================================================
echo  Step 4: Deactivate Conda and switch to .venv
echo ======================================================
call conda deactivate
call .\.venv\Scripts\activate.bat

echo ======================================================
echo  Step 5: Upgrade pip and wheel
echo ======================================================
python -m pip install -U pip wheel
if errorlevel 1 (
    echo [ERROR] pip upgrade failed.
    exit /b 1
)

echo ======================================================
echo  Step 6: Install dependencies from requirements.txt
echo ======================================================
if exist requirements.txt (
    python -m pip install -r requirements.txt
) else (
    echo ⚠️  requirements.txt not found, skipping dependency installation.
)

echo.
echo ✅ Environment setup complete!
echo To activate later, run:
echo     .\.venv\Scripts\activate
echo ======================================================

endlocal
pause
