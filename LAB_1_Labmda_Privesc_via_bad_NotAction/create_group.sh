#!/bin/bash

set -x

usage='Creates the group for marketing power users with Lambda, SQS and NotAction policies.'

source env.sh

GROUP_NAME=PowerUserAccess-marketing-group-$RAND
POLICY_NAME=PowerUserAccess-marketing-Deny-IAM-$RAND
POLICY_ARN=arn:aws:iam::${AWS_ACCOUNT_ID}:policy/${POLICY_NAME}

if [ $1 == "--delete" ]; then
 aws iam detach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess
 aws iam detach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
 #aws iam delete-group-policy --group-name $GROUP_NAME --policy-arn $POLICY_ARN 
 aws iam delete-group --group-name $GROUP_NAME
 exit 0
fi

aws iam create-group --group-name $GROUP_NAME
aws iam put-group-policy --group-name $GROUP_NAME --policy-name $POLICY_NAME --policy-document file://power_user_marketing_not_action_policy_doc.json

aws iam list-group-policies --group-name $GROUP_NAME
aws iam get-group-policy --group-name $GROUP_NAME --policy-name $POLICY_NAME

aws iam attach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess
aws iam attach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
aws iam list-attached-group-policies --group-name $GROUP_NAME



