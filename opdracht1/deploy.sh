#!/bin/bash

# Stop het script direct als er een commando faalt
set -e

echo "Start met de uitrol van de Infrastructuur..."

# ==========================================
# 1. Fundament Stack (Netwerk & Security)
# ==========================================
echo "1/6 Deploying Fundament Stack..."
aws cloudformation deploy \
  --stack-name MyFundamentStack \
  --template-file 1_fundaments.yml

# ==========================================
# 2. Data & Storage Stack (RDS & EFS)
# ==========================================
echo "2/6 Deploying Data & Storage Stack..."
aws cloudformation deploy \
  --stack-name MyStorageStack \
  --template-file 2_data\&storage.yml \
  --parameter-overrides BaseStackName=MyFundamentStack

# ==========================================
# 3. Application Stack (Load Balancer & Launch Template)
# ==========================================
echo "3/6 Deploying Application Stack..."
aws cloudformation deploy \
  --stack-name MyAppStack \
  --template-file 3_application\&loadbalancer.yml \
  --parameter-overrides BaseStackName=MyFundamentStack StorageStackName=MyStorageStack

# ==========================================
# 4. Auto Scaling Stack (ASG & Scheduled Actions)
# ==========================================
echo "4/6 Deploying Auto Scaling Stack..."
aws cloudformation deploy \
  --stack-name MyASGStack \
  --template-file 4_auto_scaling.yml \
  --parameter-overrides BaseStackName=MyFundamentStack AppStackName=MyAppStack

# ==========================================
# 5. ELK Stack (Monitoring)
# ==========================================
echo "5/6 Deploying Monitoring Stack..."
aws cloudformation deploy \
  --stack-name MyMonitoringStack \
  --template-file 5_monitoring.yml \
  --parameter-overrides BaseStackName=MyFundamentStack StorageStackName=MyStorageStack

# ==========================================
# 6. Serverless Stack (Lambda)
# ==========================================
echo "6/6 Deploying Serverless Stack (Lambda)..."
aws cloudformation deploy \
  --stack-name MyServerlessStack \
  --template-file 6_serverless.yml \
  --capabilities CAPABILITY_NAMED_IAM

echo "Alle stacks zijn succesvol uitgerold!!!"

# Haal de DNS naam (URL) van de Load Balancer,Kibana en S3 bucket
ALB_URL=$(aws cloudformation describe-stacks --stack-name MyAppStack --query "Stacks[0].Outputs[?OutputKey=='LoadBalancerDnsName'].OutputValue" --output text)
KIBANA_URL=$(aws cloudformation describe-stacks --stack-name MyMonitoringStack --query "Stacks[0].Outputs[?OutputKey=='KibanaUrl'].OutputValue" --output text)
S3_BUCKET=$(aws cloudformation describe-stacks --stack-name MyServerlessStack --query "Stacks[0].Outputs[?OutputKey=='S3BucketName'].OutputValue" --output text)

echo "De applicatie is bereikbaar op:"
echo "http://$ALB_URL"
echo "Kibana Dashboard is bereikbaar op:"
echo "$KIBANA_URL"
echo "S3 Bucket voor Order exports:"
echo "s3://$S3_BUCKET"