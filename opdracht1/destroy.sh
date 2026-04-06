#!/bin/bash

echo "Start met het verwijderen van de infrastructuur..."
echo "Dit kan zo'n 10 tot 15 minuten duren (het verwijderen van de RDS database en de NAT Gateway kost tijd). Pak even een kopje koffie :)"

# ==========================================
# 0. Verwijder Serverless Stack (Stack 6)
# ==========================================
echo "1/6 Verwijderen van Serverless Stack (MyServerlessStack)..."
# S3 bucket moet eerst leeg zijn anders faalt CloudFormation het verwijderen
S3_BUCKET=$(aws cloudformation describe-stacks --stack-name MyServerlessStack --query "Stacks[0].Outputs[?OutputKey=='S3BucketName'].OutputValue" --output text 2>/dev/null)
if [ -n "$S3_BUCKET" ]; then
  echo "  S3 bucket '$S3_BUCKET' leegmaken..."
  aws s3 rm s3://$S3_BUCKET --recursive
fi
aws cloudformation delete-stack --stack-name MyServerlessStack
aws cloudformation wait stack-delete-complete --stack-name MyServerlessStack
echo "ServerlessStack verwijderd."

# ==========================================
# 1. Verwijder ELK Stack (Stack 5)
# ==========================================
echo "2/6 Verwijderen van Monitoring Stack (MyMonitoringStack)..."
aws cloudformation delete-stack --stack-name MyMonitoringStack
aws cloudformation wait stack-delete-complete --stack-name MyMonitoringStack
echo "MonitoringStack verwijderd."

# ==========================================
# 2. Verwijder Auto Scaling (Stack 4)
# ==========================================
echo "3/6 Verwijderen van Auto Scaling Stack (MyASGStack)..."
aws cloudformation delete-stack --stack-name MyASGStack
aws cloudformation wait stack-delete-complete --stack-name MyASGStack
echo "ASGStack verwijderd."

# ==========================================
# 3. Verwijder Applicatie & ALB (Stack 3)
# ==========================================
echo "4/6 Verwijderen van Application Stack (MyAppStack)..."
aws cloudformation delete-stack --stack-name MyAppStack
aws cloudformation wait stack-delete-complete --stack-name MyAppStack
echo "AppStack verwijderd."

# ==========================================
# 4. Verwijder Database & EFS (Stack 2)
# ==========================================
echo "5/6 Verwijderen van Data & Storage Stack (MyStorageStack)..."
aws cloudformation delete-stack --stack-name MyStorageStack
aws cloudformation wait stack-delete-complete --stack-name MyStorageStack
echo "StorageStack verwijderd."

# ==========================================
# 5. Verwijder Fundament & Netwerk (Stack 1)
# ==========================================
echo "6/6 Verwijderen van Fundament Stack (MyFundamentStack)..."
aws cloudformation delete-stack --stack-name MyFundamentStack
aws cloudformation wait stack-delete-complete --stack-name MyFundamentStack
echo "FundamentStack verwijderd."

echo "Alles is platgegooid! De AWS omgeving is weer helemaal schoon en mijn credits zijn weer veilig :))."