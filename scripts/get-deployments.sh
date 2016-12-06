# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh

# can receive API_ID
if [ $1 ]
then
  API_ID=$1
fi

getDeployments() {
  aws apigateway get-deployments --rest-api-id "$API_ID"
}

getDeployments | jq -r '.items | sort_by(.createdDate)'
