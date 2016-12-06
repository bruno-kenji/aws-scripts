# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

if [ $1 ]
then
  API_ID=$1
else
  read -p 'API ID: ' API_ID
fi

aws apigateway delete-rest-api --rest-api-id $API_ID
