#!/usr/bin/env bash
# Sends checkout orders. With a coupon (the default) every order fails, which
# fires the alarm within a couple of minutes. COUPON= sends healthy orders.
set -euo pipefail

REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-us-east-2}}"
FUNCTION="${FUNCTION_NAME:-gatepeer-e2e-checkout}"
COUNT="${COUNT:-5}"
COUPON="${COUPON-WELCOME10}"
OUTPUT="$(mktemp)"
trap 'rm -f "$OUTPUT"' EXIT
export AWS_PAGER="" AWS_CLI_AUTO_PROMPT=off

if [ -n "$COUPON" ]; then
  PAYLOAD="{\"coupon\": \"$COUPON\"}"
else
  PAYLOAD="{}"
fi

for _ in $(seq "$COUNT"); do
  aws lambda invoke --region "$REGION" --function-name "$FUNCTION" \
    --cli-binary-format raw-in-base64-out --payload "$PAYLOAD" "$OUTPUT" \
    --query FunctionError --output text
done
