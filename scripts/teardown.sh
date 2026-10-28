#!/usr/bin/env bash
# Removes everything deploy.sh created.
set -uo pipefail

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-2}}"
FUNCTION="${FUNCTION_NAME:-gatepeer-e2e-checkout}"
ROLE="${FUNCTION}-role"
export AWS_PAGER="" AWS_CLI_AUTO_PROMPT=off

aws cloudwatch delete-alarms --region "$REGION" --alarm-names "${FUNCTION}-errors"
aws lambda delete-function --region "$REGION" --function-name "$FUNCTION"
aws logs delete-log-group --region "$REGION" --log-group-name "/aws/lambda/$FUNCTION" 2>/dev/null
aws iam detach-role-policy --role-name "$ROLE" \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam delete-role --role-name "$ROLE"
echo "Removed $FUNCTION"
