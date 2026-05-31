#!/bin/bash
set -e

# Kleuren voor output
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}Stap 1: Voorbereiden van de omgeving...${NC}"
# Installeer Ansible, Kubernetes dependencies en de Kubernetes collection
pip3 install --user ansible kubernetes > /dev/null 2>&1
ansible-galaxy collection install kubernetes.core > /dev/null 2>&1

echo -e "${GREEN}Stap 2: Terraform infrastructure uitrollen...${NC}"
cd terraform
terraform init
terraform apply -auto-approve

# Haal de benodigde outputs op
ECR_URL=$(terraform output -raw ecr_repository_url)
RDS_ENDPOINT=$(terraform output -raw rds_endpoint)
CLUSTER_NAME=$(terraform output -raw eks_cluster_name)
REGION=$(terraform output -raw aws_region)

cd ..

echo -e "${GREEN}Stap 3: Kubeconfig bijwerken voor EKS...${NC}"
aws eks update-kubeconfig --name $CLUSTER_NAME --region $REGION

echo -e "${GREEN}Stap 4: Kubernetes cluster configureren met Ansible...${NC}"
cd ansible
# Voer het playbook uit met de variabelen uit Terraform
ansible-playbook configure_cluster.yml -e "ecr_repository_url=$ECR_URL rds_endpoint=$RDS_ENDPOINT"

echo -e "${GREEN}Klaar! De applicatie is uitgerold.${NC}"
echo -e "Je kunt de status van de pods bekijken met: ${GREEN}kubectl get pods${NC}"
echo -e "Je kunt het externe IP-adres vinden met: ${GREEN}kubectl get svc cloudshirt-service${NC}"
