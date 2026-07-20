SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$(dirname "$SCRIPT_DIR")"
echo "Setting up Ansible environment for AKIBA..."
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed"
    exit 1
fi
echo "✓ Python 3 found: $(python3 --version)"
VENV_DIR="$ANSIBLE_DIR/.venv"
if [ ! -d "$VENV_DIR" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
    echo "✓ Virtual environment created"
fi
source "$VENV_DIR/bin/activate"
echo "✓ Virtual environment activated"
echo "Upgrading pip..."
pip install --quiet --upgrade pip setuptools wheel
if [ -f "$ANSIBLE_DIR/requirements.txt" ]; then
    echo "Installing Python dependencies..."
    pip install --quiet -r "$ANSIBLE_DIR/requirements.txt"
    echo "✓ Dependencies installed"
else
    echo "Warning: requirements.txt not found"
fi
if command -v ansible &> /dev/null; then
    echo "✓ Ansible is ready: $(ansible --version | head -n1)"
else
    echo "Warning: Ansible not found after installation"
fi
export ANSIBLE_CONFIG="$ANSIBLE_DIR/ansible.cfg"
export ANSIBLE_ROLES_PATH="$ANSIBLE_DIR/roles"
export ANSIBLE_INVENTORY="$ANSIBLE_DIR/inventory/hosts.yml"
echo ""
echo "Environment setup complete!"
echo "================================================"
echo "Ansible Configuration:"
echo "  Config file: $ANSIBLE_CONFIG"
echo "  Roles path:  $ANSIBLE_ROLES_PATH"
echo "  Inventory:   $ANSIBLE_INVENTORY"
echo "================================================"
echo ""
echo "Next steps:"
echo "1. Update inventory/hosts.yml with your server IP"
echo "2. Create vault.yml: ansible-vault create vault.yml"
echo "3. Run deployment: ./scripts/deploy.sh -p 'your_password'"
echo ""
