#!/bin/bash

echo "⚠️ Start met het verwijderen van de CloudShirt Infrastructuur..."
echo "Dit kan zo'n 10 tot 15 minuten duren (het verwijderen van de RDS database en de NAT Gateway kost tijd). Pak even een kopje koffie!"

# ==========================================
# 1. Verwijder Auto Scaling (Stack 4)
# ==========================================
echo "🗑️ 1/4 Verwijderen van Auto Scaling Stack (MyASGStack)..."
aws cloudformation delete-stack --stack-name MyASGStack
aws cloudformation wait stack-delete-complete --stack-name MyASGStack
echo "✔ MyASGStack verwijderd."

# ==========================================
# 2. Verwijder Applicatie & ALB (Stack 3)
# ==========================================
echo "🗑️ 2/4 Verwijderen van Application Stack (MyAppStack)..."
aws cloudformation delete-stack --stack-name MyAppStack
aws cloudformation wait stack-delete-complete --stack-name MyAppStack
echo "✔ MyAppStack verwijderd."

# ==========================================
# 3. Verwijder Database & EFS (Stack 2)
# ==========================================
echo "🗑️ 3/4 Verwijderen van Data & Storage Stack (MyStorageStack)..."
aws cloudformation delete-stack --stack-name MyStorageStack
aws cloudformation wait stack-delete-complete --stack-name MyStorageStack
echo "✔ MyStorageStack verwijderd."

# ==========================================
# 4. Verwijder Fundament & Netwerk (Stack 1)
# ==========================================
echo "🗑️ 4/4 Verwijderen van Fundament Stack (MyFundamentStack)..."
aws cloudformation delete-stack --stack-name MyFundamentStack
aws cloudformation wait stack-delete-complete --stack-name MyFundamentStack
echo "✔ MyFundamentStack verwijderd."

echo "✅ Alles is platgegooid! Je AWS omgeving is weer helemaal schoon en je credits zijn veilig."