# you must setup aws-shell and aws-configure first (check the readme)

# TODO: break the execution after rollbackResource

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh
. ./support/aws-scripts/utilities/json-value-extractor.sh

read -p 'Parent resource ID: ' PARENT_ID
read -p 'Resource path (only the last part): ' PATH_PART

createResource() {
  aws apigateway create-resource \
    --rest-api-id "$API_ID" \
    --parent-id "$PARENT_ID" \
    --path-part "$PATH_PART"
}

createOptionsMethod() {
  echo "Creating the OPTIONS method for resource $RESOURCE_ID..."
  aws apigateway put-method \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "OPTIONS" \
    --authorization-type "NONE" \
    --no-api-key-required
}

putIntegration() {
  echo 'Setting up the MOCK integration request...'
  aws apigateway put-integration \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "OPTIONS" \
    --passthrough-behavior 'WHEN_NO_MATCH' \
    --type "MOCK" \
    --request-templates '{ "application/json": "{\"statusCode\": 200}" }'
}

putMethodResponse() {
  echo 'Setting up the method response for 200...'
  aws apigateway put-method-response \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "OPTIONS" \
    --status-code "200" \
    --response-models '{"application/json": "Empty"}'
}

putIntegrationResponse() {
  echo 'Setting up the integration response for 200...'
    aws apigateway put-integration-response \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "OPTIONS" \
    --status-code "200" \
    --selection-pattern "" \
    --response-templates '{"application/json": "{ }"}'
}

rollbackResource() {
  echo 'Doing a rollback on the resource...'
  aws apigateway delete-resource \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID"
}

RESOURCE_ID="$(createResource | jsonValue id)"
createOptionsMethod || rollbackResource
putIntegration || rollbackResource
putMethodResponse || rollbackResource
putIntegrationResponse || rollbackResource
