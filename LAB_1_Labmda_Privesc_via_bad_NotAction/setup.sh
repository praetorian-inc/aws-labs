#!/bin/bash

# Create the roles and policies to simulate a discovered high-privileged role which our user/attacker can attach to the lambda

usage='setup.sh [AWS_PROFILE]
       Stores the random string used as a suffix to all AWS resource names.
       Copies sample-env.sh to env.sh which is .gitignored
       Creates a random variable in env.sh and set AWS_PROFILE is passed.
       AWS_PROFILE must have admin permissions.
       Creates the policies and roles with the mistaken use of NotAction
'

set -xe

PROJECT_TAG='{ "Key"="project", "Value"="LAB_1_Lambda" }'


if [ ! -f env.sh ];then
  cp sample-env.sh env.sh
fi 

function set_var(){
    varname=$1
    varvalue=$2
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        sed -i "s|^${varname}=$|${varname}=${varvalue}|" env.sh
        # ...
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|^${varname}=$|${varname}=${varvalue}|" env.sh
            # Mac OSX
    else
        echo "os $OSTYPE not supported"
        exit 1
        # POSIX compatibility layer and Linux environment emulation for Windows
    fi
}

JQ_PATH=`which jq || ""`
if [[ x${JQ_PATH}x == xx ]]; then
 echo "please install jq.  Aborting"
 exit 1
fi

# Allow caller of script to pass in over-riding AWS_PROFILE
if [ x$1 != x ]; then
    if [ $1 == "help" ] || [ $1 == "--help" ]; then
      echo "${usage}"
      exit 0
    fi
    ARG_AWS_PROFILE=$1
    set_var AWS_PROFILE $ARG_AWS_PROFILE
else
    # Set the profile from the current ENV var. If unset, aws-cli uses 'default'.
    set_var AWS_PROFILE $AWS_PROFILE
fi

source env.sh

if [ x${RAND}x == xx ]; then
   RAND=$RANDOM
   set_var RAND $RAND
fi

echo "get AWS account ID"
AWS_ACCOUNT_ID=`aws sts get-caller-identity | jq '.Account' | sed 's/\"//g'`

if [ x${AWS_ACCOUNT_ID}x == xx ]; then
   echo "Could not get AWS_ACCOUNT_ID. Check your creds with aws sts get-caller-identity"
   exit 1
else
   set_var AWS_ACCOUNT_ID $AWS_ACCOUNT_ID
   echo "using AWS_ACCOUNT_ID $AWS_ACCOUNT_ID"
fi

POLICY_NAME=update_iam_policy_${RAND}
set_var POLICY_NAME $POLICY_NAME
set_var DISCOVERED_ROLE_NAME discovered_role_with_iam_privs_${RAND}

aws iam create-role --role-name discovered_role_with_iam_privs-${RAND} --assume-role-policy-document file://lambda_assume_policy_doc.json 
aws iam tag-role --role-name discovered_role_with_iam_privs-${RAND} --tags "${PROJECT_TAG}" || echo "Tagging not supported"
aws iam create-policy --policy-name "${POLICY_NAME}" --policy-document file://lambda_permissions_policy_doc.json > ${POLICY_NAME}_output.json
policy_arn=`cat ${POLICY_NAME}_output.json | jq '.Policy.Arn' | sed 's/\"//g' ` 
echo "policy_arn=${policy_arn}"
set_var POLICY_ARN ${policy_arn}
aws iam attach-role-policy --role-name discovered_role_with_iam_privs-${RAND} --policy-arn "${policy_arn}"
aws iam list-attached-role-policies --role-name discovered_role_with_iam_privs-${RAND}
aws iam list-policies | grep update

echo "something like: aws iam get-policy-version  --policy-arn arn:aws:iam::11111111111:policy/update_iam_policy_xxkd9300001111 --version-id v1"

exit 0
