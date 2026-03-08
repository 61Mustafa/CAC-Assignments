#!/bin/bash
# Deploy script voor CloudFormation stacks
# Gebruik: ./deploy-all.sh [assignment1|assignment2]

set -e  # Stop bij errors

DEPLOYMENT_TYPE="${1:-assignment2}"  # Default: assignment2

echo "🚀 Starting deployment..."
echo "📋 Deployment type: $DEPLOYMENT_TYPE"

# Deploy Base stack (altijd nodig)
echo ""
echo "📦 Deploying Base stack (VPC, Subnets, etc.)..."
aws cloudformation create-stack \
  --stack-name MyBase \
  --template-body file://w1_base_cf_file.yml \
  --region eu-west-1 2>/dev/null || echo "ℹ️  Base stack already exists, continuing..."

echo "⏳ Waiting for Base stack to complete..."
aws cloudformation wait stack-create-complete \
  --stack-name MyBase \
  --region eu-west-1
echo "✅ Base stack is COMPLETE!"

if [ "$DEPLOYMENT_TYPE" = "assignment1" ]; then
  # Assignment 1: Vaste instances + ALB
  echo ""
  echo "📦 Deploying Instances stack (2 fixed EC2 instances)..."
  aws cloudformation create-stack \
    --stack-name MyInstances \
    --template-body file://w2_assignment_1_instances.yml \
    --parameters ParameterKey=BaseStackName,ParameterValue=MyBase \
    --region eu-west-1

  echo "⏳ Waiting for Instances stack to complete..."
  aws cloudformation wait stack-create-complete \
    --stack-name MyInstances \
    --region eu-west-1
  echo "✅ Instances stack is COMPLETE!"

  echo ""
  echo "📦 Deploying ALB stack (Load Balancer)..."
  aws cloudformation create-stack \
    --stack-name MyALB \
    --template-body file://w2_assignment_1_alb.yml \
    --parameters ParameterKey=BaseStackName,ParameterValue=MyBase \
    --region eu-west-1

  echo "⏳ Waiting for ALB stack to complete..."
  aws cloudformation wait stack-create-complete \
    --stack-name MyALB \
    --region eu-west-1
  echo "✅ ALB stack is COMPLETE!"

<<<<<<< Updated upstream
  # Get the URL
  echo ""
  echo "🎉 ASSIGNMENT 1 DEPLOYED SUCCESSFULLY!"
  echo "🌐 Your application is available at:"
  aws cloudformation describe-stacks \
    --stack-name MyALB \
    --region eu-west-1 \
    --query "Stacks[0].Outputs[?OutputKey=='ALBDNSName'].OutputValue" \
    --output text

elif [ "$DEPLOYMENT_TYPE" = "assignment2" ]; then
  # Assignment 2: Auto Scaling Group (met ingebouwde ALB)
  echo ""
  echo "📦 Deploying Auto Scaling Group stack..."
  aws cloudformation create-stack \
    --stack-name MyASG \
    --template-body file://w2_autoscaling.yml \
    --parameters ParameterKey=BaseStackName,ParameterValue=MyBase \
    --region eu-west-1

  echo "⏳ Waiting for Auto Scaling stack to complete..."
  aws cloudformation wait stack-create-complete \
    --stack-name MyASG \
    --region eu-west-1
  echo "✅ Auto Scaling stack is COMPLETE!"

  # Get the URL
  echo ""
  echo "🎉 ASSIGNMENT 2 DEPLOYED SUCCESSFULLY!"
  echo "🌐 Your application is available at:"
  aws cloudformation describe-stacks \
    --stack-name MyASG \
    --region eu-west-1 \
    --query "Stacks[0].Outputs[?OutputKey=='ALBDNSName'].OutputValue" \
    --output text
  
  echo ""
  echo "📊 To test auto scaling:"
  echo "   1. Open the URL above in your browser"
  echo "   2. Refresh multiple times quickly (3-5 times)"
  echo "   3. Check AWS Console → EC2 → Auto Scaling Groups → WebAppASG"
  echo "   4. Watch new instances being created!"

else
  echo "❌ Invalid deployment type. Use: assignment1 or assignment2"
  exit 1
fi
=======
# Get the URL
echo ""
echo "🎉 ALL STACKS DEPLOYED SUCCESSFULLY!"
echo "🌐 Your application is available at:"
aws cloudformation describe-stacks \
  --stack-name MyALB \
  --region us-east-1 \
  --query "Stacks[0].Outputs[?OutputKey=='ALBDNSName'].OutputValue" \
  --output text
>>>>>>> Stashed changes
