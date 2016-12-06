# you must setup aws-shell and aws-configure first (check the readme)
# YOU MUST RUN THIS FROM PROJECT ROOT!

#!/bin/bash

ROLE_URI_PREFIX="arn:aws:iam::"

# gets Arn attribute from JSON response, then extracts the account id from it
ACCOUNT_ID="$(aws iam get-user | jq -r '.User.Arn' | sed -e 's/.*::\(.*\):.*/\1/')"

# can receive the lambda name as an argument
if [ $1 ]
then
  LAMBDA_NAME=$1
else
  read -p "Lambda name (not the file name!): " LAMBDA_NAME
fi

read -p "IAM role (lambda execution role): " ROLE_NAME

RUNTIME='nodejs4.3'
HANDLER="${LAMBDA_NAME,,}.default"
ROLE_URI="${ROLE_URI_PREFIX}${ACCOUNT_ID}:role/${ROLE_NAME}"

zipFile() {
  ZIP_PATH=~/Desktop
  zip -FSr $ZIP_PATH/${LAMBDA_NAME,,}.js.zip ${LAMBDA_NAME,,}.js
}

createLambda() {
  aws lambda create-function \
    --function-name "$LAMBDA_NAME" \
    --runtime "$RUNTIME" \
    --handler "$HANDLER" \
    --role "$ROLE_URI" \
    --zip-file fileb://$ZIP_PATH/${LAMBDA_NAME,,}.js.zip
}

cd ./dist
zipFile
cd ..

createLambda
