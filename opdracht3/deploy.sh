#!/bin/bash
set -e

echo "=== CloudShirt opdracht 3 - Uitrol ==="

# 1. Infrastructuur uitrollen met Terraform
echo "[1/3] Terraform: infrastructuur uitrollen (dit duurt ~15-20 min voor EKS)..."
cd terraform
terraform init -input=false
terraform apply -auto-approve
cd ..

# 2. Docker image bouwen en pushen (VEREIST een Docker daemon!)
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  echo "[2/3] Docker image bouwen en pushen naar ECR..."
  cd terraform
  bash "docker-build&push.sh"
  cd ..
else
  echo "[2/3] LET OP: Docker is hier niet beschikbaar (CloudShell heeft geen Docker daemon)."
  echo "      Bouw en push de image op een machine MET Docker via terraform/docker-build&push.sh."
  echo "      Daarna kun je de Ansible-stap los draaien."
fi

# 3. Applicatie deployen op het cluster met Ansible
echo "[3/3] Ansible: cluster configureren en applicatie deployen..."
cd ansible
ansible-playbook -i inventory.ini configure_cluster.yml
cd ..

echo "=== Klaar! De externe URL staat hierboven in de Ansible-output. ==="