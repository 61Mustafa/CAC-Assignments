cat > deploy-all.sh << 'EOF'
#!/bin/bash
set -e  # Stop bij errors

echo "🚀 Starting deployment of all stacks..."

# Deploy Base
echo "📦 Deploying Base stack (VPC, Subnets, etc.)..."
aws cloudformation create-stack \
  --stack-name MyBase \
  --template-body file://w1_base_cf_file.yml \
  --region us-east-1

echo "⏳ Waiting for Base stack to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name MyBase \
  --region us-east-1
echo "✅ Base stack is COMPLETE!"

# Deploy Instances
echo "📦 Deploying Instances stack (2 EC2 instances)..."
aws cloudformation create-stack \
  --stack-name MyInstances \
  --template-body file://w2_assignment_1_instances.yml \
  --region us-east-1

echo "⏳ Waiting for Instances stack to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name MyInstances \
  --region us-east-1
echo "✅ Instances stack is COMPLETE!"

# Deploy ALB
echo "📦 Deploying ALB stack (Load Balancer)..."
aws cloudformation create-stack \
  --stack-name MyALB \
  --template-body file://w2_assignment_1_alb.yml \
  --region us-east-1

echo "⏳ Waiting for ALB stack to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name MyALB \
  --region us-east-1
echo "✅ ALB stack is COMPLETE!"

# Get the URL
echo ""
echo "🎉 ALL STACKS DEPLOYED SUCCESSFULLY!"
echo "🌐 Your application is available at:"
aws cloudformation describe-stacks \
  --stack-name MyALB \
  --region us-east-1 \
  --query "Stacks[0].Outputs[?OutputKey=='ALBDNSName'].OutputValue" \
  --output text
EOF

# Maak het uitvoerbaar
chmod +x deploy-all.sh

# Run het script
./deploy-all.sh