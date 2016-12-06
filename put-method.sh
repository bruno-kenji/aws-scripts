# you must setup aws-shell and aws-configure first (check the readme)
# TODO: implement HTTP headers and querystrings

#!/bin/bash

# .main.sh provides API_ID and RESPONSE_TEMPLATES
. ./support/aws-scripts/.main.sh
. ./support/aws-scripts/utilities/yaml2json.sh

REGION="$(aws configure get region)"
API_NAME="$(aws apigateway get-rest-api --rest-api-id $API_ID | jq -r '.name')"
AUTH_TYPE='NONE'

read -p 'Resource ID: ' RESOURCE_ID
read -p 'HTTP method: ' HTTP_METHOD
HTTP_METHOD=${HTTP_METHOD^^}
read -p 'Lambda name: ' LAMBDA_NAME
read -n1 -p 'HTTP Request Headers? [y,n]' HAS_HEADERS
printf '\n'
read -n1 -p 'URL Query Strings? [y,n]' HAS_QUERY_STRINGS
printf '\n'
read -n1 -p 'Require API key? [y,n]' API_KEY_REQUIRED
printf '\n'
# read -p 'Integration type [HTTP, AWS, MOCK, HTTP_PROXY, AWS_PROXY]: ' TYPE
INTEGRATION_TYPE='AWS'
# read -p 'Integration HTTP method: ' INTEGRATION_HTTP_METHOD
INTEGRATION_HTTP_METHOD="$HTTP_METHOD"

if [ ${HAS_HEADERS,,} = 'y' ]
then
  HEADERS="$(yaml2json ./support/aws-scripts/"$API_NAME"/"${LAMBDA_NAME,,}"/request-headers.yaml | sed -e 's/"/\"method.request.header./')"
else
  HEADERS={}
fi

if [ ${HAS_QUERY_STRINGS,,} = 'y' ]
then
  QUERY_STRINGS="$(yaml2json ./support/aws-scripts/"$API_NAME"/"${LAMBDA_NAME,,}"/request-querystrings.yaml | sed -e 's/"/\"method.request.querystring./')"
else
  QUERY_STRINGS={}
fi

METHOD_REQUEST_PARAMS=$(ruby -rjson -e "puts(JSON.pretty_generate(${QUERY_STRINGS}.to_h.merge(${HEADERS}.to_h)))")
echo $METHOD_REQUEST_PARAMS
LAMBDA_URI="$(aws lambda get-function --function-name ${LAMBDA_NAME} | jq -r '.Configuration.FunctionArn')"

putMethod() {
  echo 'Creating method...'
  case $API_KEY_REQUIRED in
    y|Y) aws apigateway put-method \
      --rest-api-id "$API_ID" \
      --resource-id "$RESOURCE_ID" \
      --http-method "$HTTP_METHOD" \
      --authorization-type "$AUTH_TYPE" \
      --request-parameters "$METHOD_REQUEST_PARAMS" \
      --api-key-required;;
    n|N) aws apigateway put-method \
      --rest-api-id "$API_ID" \
      --resource-id "$RESOURCE_ID" \
      --http-method "$HTTP_METHOD" \
      --authorization-type "$AUTH_TYPE" \
      --request-parameters "$METHOD_REQUEST_PARAMS" \
      --no-api-key-required;;
    *) echo "Error";;
  esac
}

putIntegration() {
  echo 'Setting up the integration request...'
  aws apigateway put-integration \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "$HTTP_METHOD" \
    --type "$INTEGRATION_TYPE" \
    --passthrough-behavior 'WHEN_NO_TEMPLATES' \
    --integration-http-method "$INTEGRATION_HTTP_METHOD" \
    --uri "arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_URI}/invocations"
}

# receives all the HTTP status codes
putMethodResponses() {
  echo 'Setting up the method responses...'
  for statusCode in "$@"
  do
    putMethodResponse "$statusCode" || { rollbackMethod; break; }
  done
}

# receives one HTTP statusCode as a parameter
putMethodResponse() {
  aws apigateway put-method-response \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "$HTTP_METHOD" \
    --status-code "$1" \
    --response-parameters "method.response.header.Access-Control-Allow-Origin=false" \
    --response-models '{"application/json": "Empty"}'
}

# receives all the HTTP status codes
putIntegrationResponses() {
  echo 'Setting up the integration responses...'
  for statusCode in "$@"
  do
    putIntegrationResponse "$statusCode" || { rollbackMethod; break; }
  done
}

putDefaultIntegrationResponse() {
  aws apigateway put-integration-response \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "$HTTP_METHOD" \
    --status-code "$1" \
    --selection-pattern "" \
    --response-templates "$RESPONSE_TEMPLATES"
}

# receives one HTTP statusCode as a parameter
putIntegrationResponse() {
  aws apigateway put-integration-response \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "$HTTP_METHOD" \
    --status-code "$1" \
    --selection-pattern ".*\"statusCode\":\"${1}\".*" \
    --response-templates "$RESPONSE_TEMPLATES" \
    --response-parameters '{ "method.response.header.Access-Control-Allow-Origin": '"\"'*'\""' }'
}

rollbackMethod() {
  echo 'Doing a rollback on the method...'
  aws apigateway delete-method \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method "$HTTP_METHOD"
}

if putMethod
then
  putIntegration || rollbackMethod
  putMethodResponses 200 401 403 404 422 500 502 504 || rollbackMethod
  putDefaultIntegrationResponse 200 || rollbackMethod
  putIntegrationResponses 200 400 401 403 404 422 500 502 504 || rollbackMethod
fi
