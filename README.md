### Setup
Include aws-scripts inside your existing project  
aws-scripts expect your lambdas to be inside *project_root/dist*  

The expected path to the script is:  
*project_root/support/aws-scripts*  
**Change this at your discretion**

### Install aws-shell and set aws configure according to the docs:
https://github.com/awslabs/aws-shell

### Setting up the main variables
See .main.sh.sample and create the .main.sh file

### Mapping the integration requests for each lambda
Use the following structure:  
api-name > lambda-name > request-headers.yaml # used on put-method.sh
api-name > lambda-name > request-querystrings.yaml #used on put-method.sh
api-name > lambda-name > request-template.yaml //used on put-integration.sh
api-name > lambda-name > invocation-params.json #used on invoke-lambda.sh

### Running a script
Execute the desired script via bash with root authorization, ie:
```
. ./support/get-apis.sh
```

ALWAYS EXECUTE FROM PROJECT ROOT
