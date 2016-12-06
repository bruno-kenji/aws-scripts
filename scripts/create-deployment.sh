# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh

# can receive API_ID
if [ $1 ]
then
  API_ID=$1
fi

read -p 'Description: ' DESCRIPTION

aws apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --description "$DESCRIPTION"
