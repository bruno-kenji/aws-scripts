# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh
. ./support/aws-scripts/utilities/yaml2json.sh

REGION="$(aws configure get region)"
API_NAME="$(aws apigateway get-rest-api --rest-api-id $API_ID | jq -r '.name')"

read -p 'Resource ID: ' RESOURCE_ID
read -p 'HTTP method: ' HTTP_METHOD
HTTP_METHOD="${HTTP_METHOD^^}"
read -p 'Lambda name: ' LAMBDA_NAME
# LAMBDA_NAME='integration-test'

REQUEST_TEMPLATE=$(echo $(yaml2json ./support/aws-scripts/"$API_NAME"/"${LAMBDA_NAME,,}"/request-template.yaml | sed 's/"/\\"/g'))
REQUEST_TEMPLATES='{
  "application/json": "#set($allInputs = $input.path('\''$'\''))\n'"$REQUEST_TEMPLATE"'"
}'

# read -p 'Integration type [HTTP, AWS, MOCK, HTTP_PROXY, AWS_PROXY]: ' TYPE
INTEGRATION_TYPE='AWS'
# read -p 'Integration HTTP method: ' INTEGRATION_HTTP_METHOD
INTEGRATION_HTTP_METHOD="$HTTP_METHOD"

LAMBDA_URI="$(aws lambda get-function --function-name ${LAMBDA_NAME} | jq -r '.Configuration.FunctionArn')"

aws apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$RESOURCE_ID" \
  --http-method "$HTTP_METHOD" \
  --type "$INTEGRATION_TYPE" \
  --integration-http-method "$INTEGRATION_HTTP_METHOD" \
  --passthrough-behavior 'WHEN_NO_TEMPLATES' \
  --request-templates "$REQUEST_TEMPLATES" \
  --uri "arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_URI}/invocations"
