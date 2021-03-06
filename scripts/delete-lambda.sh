# you must setup aws-shell and aws-configure first (check the readme)

#!/bin/bash

# can receive lambda name
if [ $1 ]
then
  LAMBDA_NAME=$1
else
  read -p "Lambda name (not the file name!): " LAMBDA_NAME
fi

aws lambda delete-function --function-name "$LAMBDA_NAME"
