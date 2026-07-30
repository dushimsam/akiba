#!/bin/bash
set -e
cd "$(dirname "$0")/.."
ansible-playbook configure.yml -i inventory/hosts.yml --ask-vault-pass -e "postgres_password=${1:-}"