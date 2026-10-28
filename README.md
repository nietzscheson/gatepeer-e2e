# gatepeer-e2e

A tiny checkout service used as the target of [Gatepeer](https://github.com/nietzscheson/gatepeer)'s
end-to-end test. It runs as an AWS Lambda with a CloudWatch alarm on its
`Errors` metric. Orders with a coupon fail, the alarm fires, and Gatepeer's
triage agent has to find out why from the alarm, the logs and the recent
changes in this repository.

## Use

Needs AWS credentials for the target account in the shell.

```bash
scripts/deploy.sh      # Lambda gatepeer-e2e-checkout + alarm gatepeer-e2e-checkout-errors
scripts/order.sh       # 5 orders with coupon WELCOME10 -> errors -> ALARM
COUPON= scripts/order.sh   # healthy orders
scripts/teardown.sh    # remove everything
```

`AWS_REGION` (default `us-east-2`), `FUNCTION_NAME` and `COUNT` can be
overridden.

## Tests

```bash
python -m pytest tests
```
