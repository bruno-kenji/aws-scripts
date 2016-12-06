# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh

# can receive RESOURCE ID
if [ $1 ]
then
  RESOURCE_ID=$1
else
  read -p 'RESOURCE ID: ' RESOURCE_ID
fi

aws apigateway get-resource --rest-api-id "$API_ID" --resource-id "$RESOURCE_ID"
