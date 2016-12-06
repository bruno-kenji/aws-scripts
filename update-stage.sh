# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# .main.sh provides API_ID
. ./support/aws-scripts/.main.sh

# can receive API_ID
if [ $1 ]
then
  API_ID=$1
fi

read -p 'Stage name: ' STAGE_NAME
read -n1 -p 'Use last deployment? [y,n]' USE_LAST_DEPLOYMENT
printf '\n'

getDeployments() {
  aws apigateway get-deployments --rest-api-id "$1"
}

case $USE_LAST_DEPLOYMENT in
  y|Y) DEPLOYMENT_ID=$(getDeployments "$API_ID" | jq -r '.items | sort_by(.createdDate) | .[-1] | .id');;
  n|N) read -p 'Deployment ID: ' DEPLOYMENT_ID;;
  *) echo "Error";;
esac

aws apigateway update-stage \
  --stage-name "$STAGE_NAME" \
  --rest-api-id "$API_ID" \
  --patch-operations "op=replace, path=/deploymentId, value=$DEPLOYMENT_ID"
