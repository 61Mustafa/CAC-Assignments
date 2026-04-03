#!/bin/bash

# Stop het script direct als er een commando faalt
set -e

echo "Start met de uitrol van de Infrastructuur..."

# ==========================================
# 1. Fundament Stack (Netwerk & Security)
# ==========================================
echo "1/4 Deploying Fundament Stack..."
aws cloudformation deploy \
  --stack-name MyFundamentStack \
  --template-file 1_fundaments.yml

# ==========================================
# 2. Data & Storage Stack (RDS & EFS)
# ==========================================
echo "2/4 Deploying Data & Storage Stack"
aws cloudformation deploy \
  --stack-name MyStorageStack \
  --template-file 2_data\&storage.yml \
  --parameter-overrides BaseStackName=MyFundamentStack

# ==========================================
# 3. Application Stack (Load Balancer & Launch Template)
# ==========================================
echo "3/4 Deploying Application Stack..."
aws cloudformation deploy \
  --stack-name MyAppStack \
  --template-file 3_application\&loadbalancer.yml \
  --parameter-overrides BaseStackName=MyFundamentStack StorageStackName=MyStorageStack

# ==========================================
# 4. Auto Scaling Stack (ASG & Scheduled Actions)
# ==========================================
echo "4/4 Deploying Auto Scaling Stack..."
aws cloudformation deploy \
  --stack-name MyASGStack \
  --template-file 4_auto_scaling.yml \
  --parameter-overrides BaseStackName=MyFundamentStack AppStackName=MyAppStack

echo "Alle stacks zijn succesvol uitgerold!!!"

# Haal de DNS naam (URL) van de Load Balancer op
ALB_URL=$(aws cloudformation describe-stacks --stack-name MyAppStack --query "Stacks[0].Outputs[?OutputKey=='LoadBalancerDnsName'].OutputValue" --output text)

echo "De applicatie is bereikbaar op:"
echo "http://$ALB_URL"