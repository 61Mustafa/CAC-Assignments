#!/bin/bash

# Stop het script direct als er een commando faalt
set -e

# Kleuren voor output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}Start met de uitrol van Opdracht 3 (Terraform, K8s, Ansible)...${NC}"

# ==========================================
# 1. Omgeving voorbereiden
# ==========================================
echo -e "${YELLOW}1/4 Omgeving voorbereiden...${NC}"

# Zorg dat ~/.local/bin in PATH staat voor Ansible
export PATH=$PATH:$HOME/.local/bin

# Controleer of dependencies aanwezig zijn, installeer indien nodig
if ! command -v ansible &> /dev/null; then
    echo "Ansible niet gevonden. Installeren..."
    # Probeer eerst zonder --user (nodig in venvs), dan met --user (voor standaard CloudShell)
    python3 -m pip install ansible kubernetes || python3 -m pip install --user ansible kubernetes
else
    echo "Ansible is al geïnstalleerd."
fi

# Controleer of Terraform aanwezig is
if ! command -v terraform &> /dev/null; then
    echo "Terraform niet gevonden. Installeren..."
    TF_VERSION="1.9.5"
    ARCH=$(uname -m)
    if [[ "$ARCH" == "x86_64" ]]; then TF_ARCH="amd64"; else TF_ARCH="arm64"; fi
    curl -sLO "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_${TF_ARCH}.zip"
    
    if command -v unzip &> /dev/null; then
        unzip -o "terraform_${TF_VERSION}_linux_${TF_ARCH}.zip"
    else
        python3 -c "import zipfile, sys; zipfile.ZipFile(sys.argv[1]).extractall()" "terraform_${TF_VERSION}_linux_${TF_ARCH}.zip"
    fi
    
    mkdir -p "$HOME/.local/bin"
    mv terraform "$HOME/.local/bin/"
    rm "terraform_${TF_VERSION}_linux_${TF_ARCH}.zip"
else
    echo "Terraform is al geïnstalleerd."
fi

echo "Installeren van Kubernetes collection voor Ansible..."
ansible-galaxy collection install kubernetes.core --force

# ==========================================
# 2. Terraform (Infrastructuur)
# ==========================================
echo -e "${YELLOW}2/4 Terraform infrastructure uitrollen (dit kan 15-20 min duren)...${NC}"
cd terraform

echo "Initialiseren..."
terraform init

echo "Toepassen van wijzigingen..."
terraform apply -auto-approve

# Haal de benodigde outputs op
ECR_URL=$(terraform output -raw ecr_repository_url)
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=$(terraform output -raw aws_region)

cd ..

# ==========================================
# 3. Kubeconfig bijwerken
# ==========================================
echo -e "${YELLOW}3/4 Kubeconfig bijwerken voor EKS cluster: $CLUSTER_NAME...${NC}"
aws eks update-kubeconfig --name "$CLUSTER_NAME" --region "$REGION"

# ==========================================
# 4. Ansible (Configuratie)
# ==========================================
echo -e "${YELLOW}4/4 Kubernetes cluster configureren met Ansible...${NC}"
cd ansible

# Voer het playbook uit met de variabelen uit Terraform
ansible-playbook configure_cluster.yml -e "ecr_repository_url=$ECR_URL rds_endpoint=$RDS_ENDPOINT"

cd ..

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}Alle resources zijn succesvol uitgerold!!!${NC}"
echo -e "${GREEN}==========================================${NC}"
echo -e "De applicatie is bereikbaar via de LoadBalancer."
echo -e "Status van de pods: ${YELLOW}kubectl get pods${NC}"
echo -e "Extern IP-adres: ${YELLOW}kubectl get svc cloudshirt-service${NC}"
echo -e "RDS Endpoint: ${YELLOW}$RDS_ENDPOINT${NC}"
echo -e "ECR Repository: ${YELLOW}$ECR_URL${NC}"
