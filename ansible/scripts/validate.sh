#!/bin/bash
set -e
cd "$(dirname "$0")/.."
ansible-playbook configure.yml --syntax-check