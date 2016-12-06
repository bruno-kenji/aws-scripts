# you must setup aws-shell and aws-configure first (check the readme)
# YOU MUST RUN THIS FROM PROJECT ROOT!

#!/bin/bash

# can receive lambda name
if [ $1 ]
then
  LAMBDA_NAME=$1
else
  read -p "Lambda name (not the file name!): " LAMBDA_NAME
fi

zipFile() {
  ZIP_PATH=~/Desktop
  zip -FSr $ZIP_PATH/${LAMBDA_NAME,,}.js.zip ${LAMBDA_NAME,,}.js
}

updateLambda() {
aws lambda update-function-code \
  --function-name ${LAMBDA_NAME} \
  --zip-file fileb://$ZIP_PATH/${LAMBDA_NAME,,}.js.zip
}

cd ./dist
zipFile
cd ..

updateLambda
