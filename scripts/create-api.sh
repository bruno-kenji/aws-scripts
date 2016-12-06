# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

read -p 'API Name: ' API_NAME
read -p 'API Description: ' API_DESCRIPTION
read -n1 -p 'Clone from another API? [y,n]' WILL_CLONE

printf '\n'

case $WILL_CLONE in
  y|Y) read -p 'API ID to clone from: ' CLONE_ID && aws apigateway create-rest-api --name "$API_NAME" --description "$API_DESCRIPTION" --clone-from "$CLONE_ID";;
  n|N) aws apigateway create-rest-api --name "$API_NAME" --description "$API_DESCRIPTION";;
  *) echo "Error";;
esac
