# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh

AUTH_TYPE='NONE'

read -p 'Resource ID: ' RESOURCE_ID
read -p 'HTTP method: ' HTTP_METHOD
HTTP_METHOD="${HTTP_METHOD^^}"

deleteMethod() {
  aws apigateway delete-method \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "$HTTP_METHOD"
}

if deleteMethod
then
  echo 'Method deleted successfully'
fi
