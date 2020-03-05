set -x

GROUP_NAME=PowerUserAccess-marketing-group
POLICY_NAME=PowerUserAccess-marketing-Deny-IAM

aws iam create-group --group-name $GROUP_NAME
aws iam put-group-policy --group-name $GROUP_NAME --policy-name $POLICY_NAME --policy-document file://power_user_marketing_policy_doc.json

aws iam list-group-policies --group-name $GROUP_NAME
aws iam get-group-policy --group-name $GROUP_NAME --policy-name $POLICY_NAME

aws iam attach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::aws:policy/AmazonSQSFullAccess
aws iam attach-group-policy --group-name $GROUP_NAME --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
aws iam list-attached-group-policies --group-name $GROUP_NAME



