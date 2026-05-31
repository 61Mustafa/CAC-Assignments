#!/bin/bash
set -e

# 1. Regio en account-ID bepalen
REGION=$(aws configure get region 2>/dev/null) || REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-1}}"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# 2. ECR-URL ophalen uit de Terraform output (draai dit vanuit je terraform map)
ECR_URL=$(terraform output -raw ecr_repository_url)

# 3. Broncode en Dockerfile klaarzetten
cd /tmp
rm -rf CloudShirt CAC-Assignments
git clone https://github.com/looking4ward/CloudShirt.git
git clone https://github.com/61Mustafa/CAC-Assignments.git
cp CAC-Assignments/opdracht2/Dockerfile CloudShirt/Dockerfile

# 4. Image bouwen (DOCKER_BUILDKIT=0 vanwege overlay-fs beperking in CloudShell)
cd CloudShirt
DOCKER_BUILDKIT=0 docker build --pull -t cloudshirt-web:latest -f Dockerfile .

# 5. Inloggen op ECR en pushen
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
docker tag cloudshirt-web:latest $ECR_URL:latest
docker push $ECR_URL:latest

echo "Klaar! Image gepusht naar $ECR_URL:latest"