#!/usr/bin/env bash
# setup_env.sh
set -euo pipefail

ENV_NAME="py312"
PY_VER="3.12"
TIMESAT_VER="4.1.7.dev0"

echo "======================================================"
echo " Step 1: Create or update Conda environment: $ENV_NAME"
echo "======================================================"
if ! command -v conda &> /dev/null; then
  echo "[ERROR] Conda not found. Please install Miniconda or Anaconda first."
  exit 1
fi

if ! conda env list | grep -q "^$ENV_NAME\s"; then
  echo "Creating new environment '$ENV_NAME' with Python $PY_VER..."
  conda create -y -n "$ENV_NAME" "python=$PY_VER"
else
  echo "Environment '$ENV_NAME' already exists. Proceeding..."
fi

echo "======================================================"
echo " Step 2: Activate the environment"
echo "======================================================"
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "$ENV_NAME"

echo "======================================================"
echo " Step 3: Upgrade pip and wheel"
echo "======================================================"
python -m pip install -U pip wheel

echo "======================================================"
echo " Step 4: Install dependencies from requirements.txt"
echo "======================================================"
if [ -f requirements.txt ]; then
  python -m pip install -r requirements.txt
else
  echo "⚠️  requirements.txt not found. Skipping dependency installation."
fi

echo "======================================================"
echo " Step 5: Install TIMESAT $TIMESAT_VER from TestPyPI"
echo "======================================================"
python -m pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple timesat==4.1.7.dev0
python -c "import timesat, timesat._timesat as _; print('timesat', timesat.__version__, 'OK')"

echo "======================================================"
echo " ✅ Environment setup complete"
echo "======================================================"
echo "To activate later, run:"
echo "    conda activate $ENV_NAME"
