#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Logs verzamelen met Ansible...${NC}"
cd ansible
ansible-playbook collect_logs.yml

echo -e "${GREEN}Logs zijn opgeslagen in de 'ansible/logs/' map.${NC}"
