set -x

aws iam list-policy-versions --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess
aws iam get-policy-version --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess --version-id v8
