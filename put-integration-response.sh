# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID and RESPONSE_TEMPLATES
. ./support/aws-scripts/.main.sh

read -p 'Resource ID: ' RESOURCE_ID
read -p 'HTTP method: ' HTTP_METHOD
read -p 'Status code: ' STATUS_CODE

# receives one HTTP statusCode as a parameter
putIntegrationResponse() {
  aws apigateway put-integration-response \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "$HTTP_METHOD" \
    --status-code "$STATUS_CODE" \
    --selection-pattern ".*\"statusCode\":\"${STATUS_CODE}\".*" \
    --response-templates "$RESPONSE_TEMPLATES" \
    --response-parameters '{ "method.response.header.Access-Control-Allow-Origin": '"\"'*'\""' }'
}

putIntegrationResponse
