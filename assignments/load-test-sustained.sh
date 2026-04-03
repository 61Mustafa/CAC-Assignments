#!/bin/bash

# ============================================
# SUSTAINED LOAD TEST FOR AUTO SCALING
# ============================================
# This script generates continuous load for 6+ minutes
# to trigger Target Tracking Auto Scaling.
#
# Requirements:
# - 2 instances running (DesiredCapacity = 2)
# - Threshold = 0.1 requests per target
# - Minimum sustained rate = 0.1 × 2 = 0.2 req/sec
# - Test rate = 1 req/sec (5× threshold for guaranteed trigger)
#
# Expected behavior:
# - After 3 minutes: ASG scales to 3 instances
# - After 5-6 minutes: ASG scales to 4 instances (max)
# ============================================

# Get ALB DNS from CloudFormation
ALB_DNS=$(aws cloudformation describe-stacks \
  --stack-name MyASG \
  --region us-east-1 \
  --query 'Stacks[0].Outputs[?OutputKey==`ALBDNSName`].OutputValue' \
  --output text)

if [ -z "$ALB_DNS" ]; then
  echo "❌ Error: Could not retrieve ALB DNS name"
  echo "Make sure the MyASG stack is deployed and has an ALBDNSName output."
  exit 1
fi

# Display test configuration
echo "============================================"
echo "🚀 SUSTAINED LOAD TEST - AUTO SCALING"
echo "============================================"
echo "Target URL  : http://$ALB_DNS/"
echo "Duration    : 6 minutes (360 seconds)"
echo "Rate        : 1 request per second"
echo "Total       : ~360 requests"
echo ""
echo "Threshold   : 0.1 requests/target"
echo "Instances   : 2 (should scale to 4)"
echo ""
echo "Expected Scaling Timeline:"
echo "  Min 0-3  : 2 instances (monitoring)"
echo "  Min 3-5  : 3 instances (first scale-up)"
echo "  Min 5+   : 4 instances (max capacity)"
echo ""
echo "Monitor with:"
echo "  watch -n 30 'aws autoscaling describe-auto-scaling-groups --auto-scaling-group-name WebAppASG --region us-east-1 --query \"AutoScalingGroups[0].DesiredCapacity\"'"
echo ""
echo "Press Ctrl+C to stop early"
echo "============================================"
echo ""

# Test connectivity first
echo "🔍 Testing connectivity..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS/" --max-time 5)
if [ "$HTTP_CODE" != "200" ]; then
  echo "❌ Error: ALB returned HTTP $HTTP_CODE (expected 200)"
  echo "Please verify the ALB and instances are healthy."
  exit 1
fi
echo "✅ Connectivity OK (HTTP 200)"
echo ""

# Initialize counters
REQUEST_COUNT=0
SUCCESS_COUNT=0
FAIL_COUNT=0
START_TIME=$(date +%s)

echo "🔄 Starting load generation at $(date +%H:%M:%S)..."
echo ""

# Run for 6 minutes (360 seconds)
for i in {1..360}; do
  # Send 1 request per second (background job)
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$ALB_DNS/" --max-time 5 2>/dev/null) &
  REQUEST_COUNT=$((REQUEST_COUNT + 1))
  
  # Track success/failure (check previous request)
  if [ ! -z "$LAST_CODE" ]; then
    if [ "$LAST_CODE" = "200" ]; then
      SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
      FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
  fi
  LAST_CODE=$HTTP_CODE
  
  # Progress update every 30 seconds
  if [ $((i % 30)) -eq 0 ]; then
    ELAPSED=$(($(date +%s) - START_TIME))
    MINUTES=$((ELAPSED / 60))
    SECONDS=$((ELAPSED % 60))
    echo "[$(date +%H:%M:%S)] ⏱️  ${MINUTES}m ${SECONDS}s | Sent: $REQUEST_COUNT | Success: $SUCCESS_COUNT | Failed: $FAIL_COUNT"
  fi
  
  # Wait 1 second before next request
  sleep 1
done

# Wait for background jobs to complete
wait

# Calculate final stats
END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))
AVG_RATE=$(echo "scale=2; $REQUEST_COUNT / $TOTAL_TIME" | bc)

echo ""
echo "============================================"
echo "✅ LOAD TEST COMPLETE!"
echo "============================================"
echo "Total Requests : $REQUEST_COUNT"
echo "Successful     : $SUCCESS_COUNT"
echo "Failed         : $FAIL_COUNT"
echo "Total Time     : ${TOTAL_TIME} seconds"
echo "Average Rate   : ${AVG_RATE} req/sec"
echo ""
echo "============================================"
echo "📊 CHECK AUTO SCALING RESULTS"
echo "============================================"
echo ""
echo "1. Check current instance count:"
echo "   aws autoscaling describe-auto-scaling-groups \\"
echo "     --auto-scaling-group-name WebAppASG \\"
echo "     --region us-east-1 \\"
echo "     --query 'AutoScalingGroups[0].DesiredCapacity'"
echo ""
echo "2. Check scaling activities:"
echo "   aws autoscaling describe-scaling-activities \\"
echo "     --auto-scaling-group-name WebAppASG \\"
echo "     --region us-east-1 \\"
echo "     --max-records 5 \\"
echo "     --query 'Activities[].[StartTime,StatusCode,Description]' \\"
echo "     --output table"
echo ""
echo "3. Check CloudWatch metrics:"
echo "   aws cloudwatch get-metric-statistics \\"
echo "     --namespace AWS/ApplicationELB \\"
echo "     --metric-name RequestCountPerTarget \\"
echo "     --dimensions Name=TargetGroup,Value=targetgroup/WebAppASG-TG/c8e05082e807af64 Name=LoadBalancer,Value=app/WebAppASG-ALB/b124afef58213e2d \\"
echo "     --start-time \$(date -u -d '10 minutes ago' +%Y-%m-%dT%H:%M:%S) \\"
echo "     --end-time \$(date -u +%Y-%m-%dT%H:%M:%S) \\"
echo "     --period 60 \\"
echo "     --statistics Average \\"
echo "     --region us-east-1 \\"
echo "     --query 'sort_by(Datapoints, &Timestamp)[-10:]' \\"
echo "     --output table"
echo ""
echo "============================================"
