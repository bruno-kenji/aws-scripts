# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh

AUTH_TYPE='NONE'

read -p 'Resource ID: ' RESOURCE_ID
read -p 'HTTP method: ' HTTP_METHOD

aws apigateway get-integration --rest-api-id "$API_ID" --resource-id "$RESOURCE_ID" --http-method "$HTTP_METHOD"
