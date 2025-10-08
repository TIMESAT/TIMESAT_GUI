#!/usr/bin/env bash
set -euo pipefail

CONDA_ENV_NAME="py312"
PY_VER="3.12"

echo ">>> Step 1: Create Conda environment (Python $PY_VER)"
conda create -y -n "$CONDA_ENV_NAME" "python=$PY_VER"

source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$CONDA_ENV_NAME"

echo ">>> Step 2: Create virtual environment (venv)"
python -m venv .venv

echo ">>> Step 3: Switch to venv"
conda deactivate
source .venv/bin/activate

echo ">>> Step 4: Upgrade pip/wheel"
pip install -U pip wheel

echo ">>> Step 5: Install dependencies from requirements.txt"
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
else
    echo "⚠️ requirements.txt not found, skipping dependency installation"
fi

echo "✅ Environment setup complete"
