# Using Conda with Finly

The installation script (`install.ps1`) now automatically detects Miniconda/Anaconda and creates a dedicated environment for the project.

## Automatic Setup

When you run:
```powershell
.\install.ps1
```

The script will:
1. ✅ Detect if conda is installed
2. ✅ Check if the `finly` environment exists
3. ✅ Create it with Python 3.9 if it doesn't exist
4. ✅ Install all dependencies in the conda environment

## Manual Conda Commands

### Create environment manually:
```bash
conda create -n finly python=3.9 -y
```

### Activate environment:
```bash
conda activate finly
```

### Install dependencies:
```bash
conda activate finly
cd backend
pip install -r requirements.txt
```

### Deactivate environment:
```bash
conda deactivate
```

### Delete environment:
```bash
conda env remove -n finly
```

### List all environments:
```bash
conda env list
```

## Running with Conda

### Option 1: Use start.ps1 (Automatic)
```powershell
.\start.ps1
```
The script automatically uses the conda environment if it exists.

### Option 2: Manual Start with Conda
```bash
# Backend
cd backend
conda run -n finly python main.py

# Or activate first
conda activate finly
python main.py
```

### Option 3: System Python (No Conda)
If conda is not installed, everything works with system Python automatically.

## Benefits of Using Conda

- ✅ Isolated Python environment
- ✅ No conflicts with system packages
- ✅ Easy to reset (delete and recreate)
- ✅ Specific Python version control
- ✅ Better dependency management

## Troubleshooting

### Conda not found
If conda is installed but not found:
```powershell
# Initialize conda for PowerShell
conda init powershell
# Restart PowerShell
```

### Environment not activating
Make sure conda is initialized:
```powershell
conda init
```

### Wrong Python version in environment
Delete and recreate:
```bash
conda env remove -n finly
conda create -n finly python=3.9 -y
```

## IDE Configuration

### VS Code
1. Open Command Palette (Ctrl+Shift+P)
2. Search "Python: Select Interpreter"
3. Choose the `finly` conda environment

### PyCharm
1. Settings → Project → Python Interpreter
2. Add Interpreter → Conda Environment
3. Select existing environment: `finly`
