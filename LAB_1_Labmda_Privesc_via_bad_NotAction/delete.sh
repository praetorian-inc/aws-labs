#!/bin/bash

source env.sh

aws iam detach-role-policy --role-name ${DISCOVERED_ROLE_NAME} --policy-arn ${POLICY_ARN}
aws iam delete-role --role-name ${DISCOVERED_ROLE_NAME}
aws iam delete-policy --policy-arn ${POLICY_ARN}
