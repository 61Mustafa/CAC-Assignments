#!/bin/bash
set -e

REGION=$(aws configure get region 2>/dev/null) || REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
ECR_REPO="cloudshirt-repo"

echo "=== CloudShirt opdracht 3 - Uitrol ==="

# 1. Infrastructuur uitrollen met Terraform
echo "[1/3] Terraform: infrastructuur uitrollen (dit duurt ~15-20 min samen met EKS)..."
cd terraform
terraform init -input=false
terraform apply -auto-approve
cd ..

# 2. Image: bouwen als Docker beschikbaar is, anders checken of hij al in ECR staat
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
  echo "[2/3] Docker image bouwen en pushen naar ECR..."
  cd terraform
  bash "docker-build&push.sh"
  cd ..
elif aws ecr describe-images --repository-name "$ECR_REPO" --image-ids imageTag=latest --region "$REGION" &>/dev/null; then
  echo "[2/3] Image al aanwezig in ECR, bouwen overgeslagen."
else
  echo ""
  echo "  !! Er staat nog geen image in ECR, doe een handmatige deploy via de cloudshell omgeving zelf."
  exit 0
fi

# 3. Applicatie deployen op het cluster met Ansible
echo "[3/3] Ansible: cluster configureren en applicatie deployen..."
cd ansible
ansible-playbook -i inventory.ini configure_cluster.yml
cd ..

echo "=== Klaar! De externe URL staat hierboven in de Ansible output. ==="