#!/bin/bash

echo "Start met het verwijderen van de infrastructuur..."
echo "Dit kan zo'n 10 tot 15 minuten duren (het verwijderen van de RDS database en de NAT Gateway kost tijd). Pak even een kopje koffie :)"

# ==========================================
# 0. Verwijder ELK Stack (Stack 5)
# ==========================================
echo "1/5 Verwijderen van Monitoring Stack (MyMonitoringStack)..."
aws cloudformation delete-stack --stack-name MyMonitoringStack
aws cloudformation wait stack-delete-complete --stack-name MyMonitoringStack
echo "MonitoringStack verwijderd."

# ==========================================
# 1. Verwijder Auto Scaling (Stack 4)
# ==========================================
echo "2/5 Verwijderen van Auto Scaling Stack (MyASGStack)..."
aws cloudformation delete-stack --stack-name MyASGStack
aws cloudformation wait stack-delete-complete --stack-name MyASGStack
echo "ASGStack verwijderd."

# ==========================================
# 2. Verwijder Applicatie & ALB (Stack 3)
# ==========================================
echo "3/5 Verwijderen van Application Stack (MyAppStack)..."
aws cloudformation delete-stack --stack-name MyAppStack
aws cloudformation wait stack-delete-complete --stack-name MyAppStack
echo "AppStack verwijderd."

# ==========================================
# 3. Verwijder Database & EFS (Stack 2)
# ==========================================
echo "4/5 Verwijderen van Data & Storage Stack (MyStorageStack)..."
aws cloudformation delete-stack --stack-name MyStorageStack
aws cloudformation wait stack-delete-complete --stack-name MyStorageStack
echo "StorageStack verwijderd."

# ==========================================
# 4. Verwijder Fundament & Netwerk (Stack 1)
# ==========================================
echo "5/5 Verwijderen van Fundament Stack (MyFundamentStack)..."
aws cloudformation delete-stack --stack-name MyFundamentStack
aws cloudformation wait stack-delete-complete --stack-name MyFundamentStack
echo "FundamentStack verwijderd."

echo "Alles is platgegooid! De AWS omgeving is weer helemaal schoon en mijn credits zijn weer veilig :))."