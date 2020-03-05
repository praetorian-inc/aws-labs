# Create the roles and policies to simulate a discovered high-privileged role which our user/attacker can attach to the lambda

set -x

POLICY_NAME=update_iam_policy_xxkd93jal0

aws iam create-role --role-name discovered_role_with_iam_privs --assume-role-policy-document file://lambda_assume_policy_doc.json
aws iam create-policy --policy-name $POLICY_NAME --policy-document file://lambda_permissions_policy_doc.json > $POLICY_NAME_output.json
policy_arn=`cat ${POLICY_NAME}_output.json | jq '.Policy.Arn'` 
echo "policy_arn=${policy_arn}
aws iam attach-role-policy --role-name discovered_role_with_iam_privs --policy-arn $policy_arn
aws iam list-attached-role-policies --role-name discovered_role_with_iam_privs
aws iam list-policies | grep update
echo "something like: aws iam get-policy-version  --policy-arn arn:aws:iam::11111111111:policy/update_iam_policy_xxkd9300001111 --version-id v1"
