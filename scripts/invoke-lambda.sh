# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh

API_NAME="$(aws apigateway get-rest-api --rest-api-id $API_ID | jq -r '.name')"

# can receive lambda name
if [ $1 ]
then
  LAMBDA_NAME=$1
else
  read -p "Lambda name (not the file name!): " LAMBDA_NAME
fi

INVOKE_ARGS="${API_NAME}/${LAMBDA_NAME}/invocation-params.json"

invokeLambda() {
  aws lambda invoke-async \
    --function-name "$LAMBDA_NAME" \
    --invoke-args "$INVOKE_ARGS"
}

invokeLambda
