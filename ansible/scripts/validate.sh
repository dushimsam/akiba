set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"
echo "================================"
echo "Validating Ansible Configuration"
echo "================================"
echo ""
if ! command -v ansible &> /dev/null; then
    echo "❌ Ansible is not installed. Please install it with: pip install ansible"
    exit 1
fi
echo "✓ Ansible is installed: $(ansible --version | head -n 1)"
echo ""
echo "Checking YAML syntax..."
if command -v yamllint &> /dev/null; then
    yamllint -d relaxed configure.yml inventory/hosts.yml vars/default.yml || true
    echo "✓ YAML syntax check complete"
else
    echo "⚠ yamllint not installed (optional). Install with: pip install yamllint"
fi
echo ""
echo "Validating playbook syntax..."
ansible-playbook configure.yml --syntax-check
echo "✓ Playbook syntax is valid"
echo ""
echo "Validating inventory file..."
if [ -f inventory/hosts.yml ]; then
    ansible-inventory -i inventory/hosts.yml --list > /dev/null 2>&1 && \
        echo "✓ Inventory file is valid" || \
        echo "⚠ Warning: Inventory file may have issues"
else
    echo "⚠ Warning: inventory/hosts.yml not found"
fi
echo ""
echo "Checking required files..."
required_files=(
    "configure.yml"
    "ansible.cfg"
    "inventory/hosts.yml"
    "vars/default.yml"
    "roles/docker/tasks/main.yml"
    "roles/security/tasks/main.yml"
    "roles/application/tasks/main.yml"
)
all_files_exist=true
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ❌ $file (MISSING)"
        all_files_exist=false
    fi
done
echo ""
if [ "$all_files_exist" = true ]; then
    echo "✓ All required files found"
else
    echo "❌ Some required files are missing"
    exit 1
fi
echo ""
echo "Testing Ansible configuration..."
if grep -q "inventory = " ansible.cfg; then
    echo "  ✓ Inventory configured in ansible.cfg"
else
    echo "  ⚠ Inventory path not configured in ansible.cfg"
fi
echo ""
echo "✅ Validation complete!"
echo ""
echo "Next steps:"
echo "1. Update inventory/hosts.yml with your server IP"
echo "2. Create vault.yml with: ansible-vault create vault.yml"
echo "3. Run playbook with: ansible-playbook configure.yml -i inventory/hosts.yml -e @vault.yml"
