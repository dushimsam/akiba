"""
Dynamic Inventory Script for AKIBA Ansible
Reads from Terraform state and outputs Ansible inventory format
Usage:
    python3 dynamic_inventory.py
    
Or use directly in Ansible:
    ansible-playbook configure.yml -i ./scripts/dynamic_inventory.py
Requires:
    - Terraform state file at ../terraform/terraform.tfstate
    - Python 3.6+
"""
import json
import os
import sys
from pathlib import Path
def load_terraform_state():
    """Load Terraform state file"""
    terraform_path = Path(__file__).parent.parent.parent / "terraform" / "terraform.tfstate"
    
    if not terraform_path.exists():
        print(f"Error: Terraform state file not found at {terraform_path}", file=sys.stderr)
        sys.exit(1)
    
    try:
        with open(terraform_path, 'r') as f:
            return json.load(f)
    except json.JSONDecodeError as e:
        print(f"Error: Failed to parse Terraform state: {e}", file=sys.stderr)
        sys.exit(1)
def extract_outputs(state):
    """Extract useful outputs from Terraform state"""
    outputs = {}
    
    if 'outputs' in state:
        for key, value in state['outputs'].items():
            if isinstance(value, dict) and 'value' in value:
                outputs[key] = value['value']
            else:
                outputs[key] = value
    
    return outputs
def extract_resources(state):
    """Extract EC2 instances from Terraform state"""
    instances = {}
    
    if 'resources' in state:
        for resource in state['resources']:
            if resource.get('type') == 'aws_instance':
                for instance in resource.get('instances', []):
                    instance_id = instance.get('attributes', {}).get('id', 'unknown')
                    public_ip = instance.get('attributes', {}).get('public_ip', instance.get('attributes', {}).get('public_dns', ''))
                    
                    if public_ip:
                        instances[instance_id] = {
                            'public_ip': public_ip,
                            'tags': instance.get('attributes', {}).get('tags', {})
                        }
            
            elif resource.get('type') == 'terraform_data' and 'custom_api_vm' in resource.get('address', ''):
                pass
    
    return instances
def generate_inventory(terraform_state):
    """Generate Ansible inventory from Terraform state"""
    outputs = extract_outputs(terraform_state)
    resources = extract_resources(terraform_state)
    
    inventory = {
        'all': {
            'vars': {
                'ansible_user': 'ubuntu',
                'ansible_ssh_private_key_file': '~/.ssh/id_rsa'
            }
        },
        'web_servers': {
            'hosts': {}
        },
        '_meta': {
            'hostvars': {}
        }
    }
    
    server_ip = outputs.get('server_ip') or outputs.get('server_public_ip')
    
    if server_ip:
        inventory['web_servers']['hosts']['akiba_server_prod'] = server_ip
        inventory['_meta']['hostvars']['akiba_server_prod'] = {
            'server_env': 'production',
            'ansible_host': server_ip
        }
    
    for instance_id, instance_data in resources.items():
        if instance_data.get('public_ip'):
            inventory['web_servers']['hosts'][instance_id] = instance_data['public_ip']
            inventory['_meta']['hostvars'][instance_id] = {
                'ansible_host': instance_data['public_ip'],
                'tags': instance_data.get('tags', {})
            }
    
    if not inventory['web_servers']['hosts']:
        print("Warning: No servers found in Terraform state", file=sys.stderr)
    
    return inventory
def main():
    """Main function"""
    try:
        terraform_state = load_terraform_state()
        inventory = generate_inventory(terraform_state)
        print(json.dumps(inventory, indent=2))
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
if __name__ == '__main__':
    main()
