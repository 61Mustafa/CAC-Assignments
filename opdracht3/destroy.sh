#!/bin/bash
set -e

echo "=== CloudShirt opdracht 3 - Afbreken ==="

# 1. Eerst de Kubernetes resources verwijderen.
#    De Service (LoadBalancer) MOET als eerste weg, anders blijft de door AWS
#    aangemaakte load balancer hangen en kan Terraform de VPC niet opruimen.
echo "[1/2] Kubernetes resources verwijderen..."
cd ansible
ansible-playbook -i inventory.ini destroy_app.yml || true
cd ..

echo "Even wachten tot AWS de load balancer heeft opgeruimd..."
sleep 60

# 2. Infrastructuur afbreken met Terraform
echo "[2/2] Terraform: infrastructuur afbreken..."
cd terraform
terraform destroy -auto-approve
cd ..

echo "=== Alles opgeruimd! ==="