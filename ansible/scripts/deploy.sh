set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$SCRIPT_DIR"
INVENTORY="inventory/hosts.yml"
VAULT_FILE="vault.yml"
VERBOSE=""
CHECK_MODE=false
TAGS=""
MONGODB_PASSWORD=""
SKIP_VAULT=false
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' 
usage() {
    cat << EOF
Usage: $0 [OPTIONS]
AKIBA Ansible Deployment Script
OPTIONS:
    -h, --help              Show this help message
    -p, --password PASSWORD MongoDB password (required)
    -i, --inventory FILE    Use custom inventory file (default: $INVENTORY)
    -v, --verbose           Enable verbose output (-vv or -vvv for more)
    -vv                     Very verbose output
    -vvv                    Very very verbose output
    -c, --check             Run in check mode (dry-run)
    -t, --tags TAGS         Run specific tags (comma-separated)
    --skip-vault            Skip vault file (use only with command-line passwords)
    --validate              Validate playbook only
    --syntax-check          Check syntax only
    --list-hosts            List target hosts and exit
    --list-tasks            List tasks and exit
EXAMPLES:
    $0 -p "my_password_123"
    $0 -p "my_password_123" -vv
    $0 -p "my_password_123" -c
    $0 -p "my_password_123" -t docker
    $0 -p "my_password_123" -t security
    $0 -p "my_password_123" -t application
EOF
    exit 0
}
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
success() {
    echo -e "${GREEN}[✓]${NC} $1"
}
warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}
error() {
    echo -e "${RED}[✗]${NC} $1"
}
validate_prerequisites() {
    info "Validating prerequisites..."
    if ! command -v ansible-playbook &> /dev/null; then
        error "Ansible is not installed"
        echo "Install with: pip install ansible"
        exit 1
    fi
    success "Ansible found"
    if [ ! -f "$INVENTORY" ]; then
        error "Inventory file not found: $INVENTORY"
        exit 1
    fi
    success "Inventory file found: $INVENTORY"
    if [ ! -f "configure.yml" ]; then
        error "Playbook not found: configure.yml"
        exit 1
    fi
    success "Playbook found"
    if grep -q "YOUR_SERVER_IP\|1.2.3.4" "$INVENTORY"; then
        warning "Inventory contains placeholder values. Please update with actual server IP."
        echo "Edit: $INVENTORY"
        exit 1
    fi
}
check_vault() {
    if [ "$SKIP_VAULT" = false ] && [ ! -f "$VAULT_FILE" ]; then
        warning "Vault file not found: $VAULT_FILE"
        info "Creating vault file..."
        
        if ansible-vault create "$VAULT_FILE"; then
            success "Vault file created"
        else
            error "Failed to create vault file"
            exit 1
        fi
    fi
}
build_command() {
    local cmd="ansible-playbook configure.yml -i $INVENTORY"
    if [ "$SKIP_VAULT" = false ] && [ -f "$VAULT_FILE" ]; then
        cmd="$cmd --ask-vault-pass"
    fi
    if [ -n "$MONGODB_PASSWORD" ]; then
        cmd="$cmd -e \"mongodb_password=$MONGODB_PASSWORD\""
    fi
    if [ -n "$VERBOSE" ]; then
        cmd="$cmd $VERBOSE"
    fi
    if [ -n "$TAGS" ]; then
        cmd="$cmd --tags $TAGS"
    fi
    if [ "$CHECK_MODE" = true ]; then
        cmd="$cmd --check"
    fi
    echo "$cmd"
}
show_deployment_info() {
    echo ""
    echo "================================"
    echo "AKIBA Ansible Deployment"
    echo "================================"
    echo "Playbook:  configure.yml"
    echo "Inventory: $INVENTORY"
    
    if [ "$SKIP_VAULT" = false ] && [ -f "$VAULT_FILE" ]; then
        echo "Vault:     $VAULT_FILE (encrypted)"
    fi
    
    if [ "$CHECK_MODE" = true ]; then
        echo "Mode:      CHECK (dry-run, no changes)"
    else
        echo "Mode:      APPLY (will make changes)"
    fi
    
    if [ -n "$TAGS" ]; then
        echo "Tags:      $TAGS"
    fi
    
    if [ -n "$VERBOSE" ]; then
        echo "Verbose:   $VERBOSE"
    fi
    echo "================================"
    echo ""
}
confirm_deployment() {
    if [ "$CHECK_MODE" = true ]; then
        return 0
    fi
    
    read -p "Do you want to proceed with deployment? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        info "Deployment cancelled"
        exit 0
    fi
}
while [[ $
    case $1 in
        -h|--help)
            usage
            ;;
        -p|--password)
            MONGODB_PASSWORD="$2"
            shift 2
            ;;
        -i|--inventory)
            INVENTORY="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -vv)
            VERBOSE="-vv"
            shift
            ;;
        -vvv)
            VERBOSE="-vvv"
            shift
            ;;
        -c|--check)
            CHECK_MODE=true
            shift
            ;;
        -t|--tags)
            TAGS="$2"
            shift 2
            ;;
        --skip-vault)
            SKIP_VAULT=true
            shift
            ;;
        --validate)
            info "Validating playbook..."
            ansible-playbook configure.yml --syntax-check
            success "Playbook is valid"
            exit 0
            ;;
        --syntax-check)
            info "Checking syntax..."
            ansible-playbook configure.yml --syntax-check
            exit $?
            ;;
        --list-hosts)
            info "Target hosts:"
            ansible-inventory -i "$INVENTORY" --list | grep "name\|"
            exit 0
            ;;
        --list-tasks)
            info "Available tasks:"
            ansible-playbook configure.yml --list-tasks
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done
if [ -z "$MONGODB_PASSWORD" ]; then
    error "MongoDB password is required"
    echo ""
    usage
fi
main() {
    info "Starting AKIBA Ansible Deployment"
    echo ""
    validate_prerequisites
    echo ""
    check_vault
    echo ""
    show_deployment_info
    confirm_deployment
    info "Building deployment command..."
    CMD=$(build_command)
    
    info "Running playbook..."
    echo ""
    
    eval "$CMD"
    
    EXIT_CODE=$?
    echo ""
    
    if [ $EXIT_CODE -eq 0 ]; then
        if [ "$CHECK_MODE" = true ]; then
            success "Check mode completed successfully (no changes made)"
        else
            success "Deployment completed successfully!"
            echo ""
            echo "Next steps:"
            echo "1. Verify application: curl http://\$(ansible-inventory -i $INVENTORY --list | grep ansible_host)"
            echo "2. Check logs: ssh ubuntu@<server_ip> sudo journalctl -u akiba -f"
            echo "3. View firewall: ssh ubuntu@<server_ip> sudo ufw status"
        fi
        exit 0
    else
        error "Deployment failed with exit code $EXIT_CODE"
        exit $EXIT_CODE
    fi
}
main
