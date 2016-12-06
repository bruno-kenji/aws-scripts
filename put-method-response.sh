# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh

read -p 'Method ID: ' RESOURCE_ID
read -p 'HTTP method: ' HTTP_METHOD
read -p 'Status code: ' STATUS_CODE

aws apigateway put-method-response --rest-api-id "$API_ID" --resource-id "$RESOURCE_ID" --http-method "$HTTP_METHOD" --status-code "$STATUS_CODE"
