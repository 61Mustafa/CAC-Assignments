#!/bin/bash
set -e

# Kleuren voor output
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Logs verzamelen met Ansible...${NC}"

# Zorg dat ~/.local/bin in PATH staat voor Ansible
export PATH=$PATH:$HOME/.local/bin

cd ansible
ansible-playbook collect_logs.yml

echo -e "${GREEN}Logs zijn opgeslagen in de 'opdracht3/logs/' map.${NC}"
