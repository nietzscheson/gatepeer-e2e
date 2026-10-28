#!/usr/bin/env bash
# Deploys the checkout Lambda and a CloudWatch alarm on its Errors metric.
# Uses the AWS credentials of the current shell. Idempotent.
set -euo pipefail

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-2}}"
FUNCTION="${FUNCTION_NAME:-gatepeer-e2e-checkout}"
ROLE="${FUNCTION}-role"
ALARM="${FUNCTION}-errors"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD="$(mktemp -d)"
trap 'rm -rf "$BUILD"' EXIT
export AWS_PAGER="" AWS_CLI_AUTO_PROMPT=off

(cd "$ROOT/src" && zip -q -r "$BUILD/function.zip" .)

if ! ROLE_ARN=$(aws iam get-role --role-name "$ROLE" --query Role.Arn --output text 2>/dev/null); then
  ROLE_ARN=$(aws iam create-role --role-name "$ROLE" \
    --assume-role-policy-document '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":"lambda.amazonaws.com"},"Action":"sts:AssumeRole"}]}' \
    --query Role.Arn --output text)
  aws iam attach-role-policy --role-name "$ROLE" \
    --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
  sleep 10  # IAM propagation before Lambda can assume the new role
fi

if aws lambda get-function --region "$REGION" --function-name "$FUNCTION" >/dev/null 2>&1; then
  aws lambda update-function-code --region "$REGION" --function-name "$FUNCTION" \
    --zip-file "fileb://$BUILD/function.zip" >/dev/null
else
  aws lambda create-function --region "$REGION" --function-name "$FUNCTION" \
    --runtime python3.12 --handler handler.handler --role "$ROLE_ARN" \
    --timeout 10 --zip-file "fileb://$BUILD/function.zip" >/dev/null
fi
aws lambda wait function-updated-v2 --region "$REGION" --function-name "$FUNCTION"

aws cloudwatch put-metric-alarm --region "$REGION" \
  --alarm-name "$ALARM" \
  --alarm-description "Checkout errors (gatepeer-e2e)" \
  --namespace AWS/Lambda --metric-name Errors \
  --dimensions "Name=FunctionName,Value=$FUNCTION" \
  --statistic Sum --period 60 --evaluation-periods 1 \
  --threshold 1 --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching

echo "Deployed $FUNCTION and alarm $ALARM in $REGION"
