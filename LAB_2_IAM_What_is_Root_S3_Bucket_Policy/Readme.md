# What is Root?

In particular, what does the following mean when used as the principal in an IAM resource policy?

```
"Principal": {"AWS": ["arn:aws:iam::111122223333:root]}
```

## Introduction
This lab examines the difference between IAM vs AWS Resource based policies. In particular, we seek to understand the
policy evaluation logic for S3 buckets with cross account access. For a refresher on IAM basics, see
[Reference Policies Evaluation Logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
which is valid for when the IAM Principal and S3 Resource are in the same AWS account. 

To summarize the above, if an action is allowed by an identity-based policy, a resource-based policy, or both, then 
AWS allows the action. An explicit deny in either of these policies overrides the allow.

The situation changes for [cross account access](https://aws.amazon.com/premiumsupport/knowledge-center/cross-account-access-s3/). 
In this case, access must be explicitly allowed in both
the picincipal's AWS access policy and the resource policy. Unfortunately, the latter reference does not
mention the confused deputy issue for cross-account access which occurs when the trusted account is a
3rd party SaaS vendor. As a result, many vendors which operate on customer's S3 buckets do so insecurely.

For this lab, we will assume both AWS accounts are owned by the same entity and will leave confused deputy 
issues for Lab 4. Granting permissions to principals in an external AWS account can be done via two methods -
Direct Access and Assume Role.


Alternatively, cross-account access could be granted in a resource policy such as the following bucket policy.

demo-policy.json
```.json
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddCrossAccountPutPolicy",
      "Effect":"Allow",
      "Principal": {"AWS": ["arn:aws:iam::111122223333:root","arn:aws:iam::444455556666:root"]},
      "Action":["s3:PutObject","s3:GetObject","s3:ListBucket"],
      "Resource":["arn:aws:s3:::mybucket/*", "arn:aws:s3:::mybucket"],
        "Condition": {
          "IpAddress": {
            "aws:SourceIp": [
              "54.240.143.0/24",
              "54.240.144.0/24"
            ]
          }
        }
      }
    ]
  }
```

Quesitons:

* Can we modify Bucket Policies from non-whitelisted IPs (control plane, not data plane commands)?


### Assume Role
Assume Role access requires adding statements 
like the following in a role's assume-role trust policy.

IAM Role Assume-Role Trust Policy
```
"Principal":{"AWS":"arn:aws:iam::AWSTargetAccountID:root"}
```

## Setup
In order to test this, you will want two accounts where you have been granted admin, since you will need the ability
to create users, roles and policies. If an instructor wanted to run this in a class without granting full admin, then
a permissions boundary which allows creating roles and users, but not policies could be tailored to this lab following
the [AWS documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html).

```
cp demo-vars.txt vars.txt
session_random=${RANDOM}-${RANDOM}
echo "mybucket=mybucket-$session_random" >> vars.txt
```

replace the RHS of the following in 
vars.txt
```.env
internal_account=111122223333 
external account=444455556666 
cidr_1=54.240.143.0/24
cidr_2=54.240.144.0/24
```

```.bash
source vars.txt
for file in `ls demo-*.json`; do
output_name=`echo $file | sed 's|demo-||'`
cat $file \
| sed "s|111122223333|$internal_account|g" \
| sed "s|444455556666|$external_account|g" \
| sed "s|54.240.143.0/24|$cidr_1|g" \
| sed "s|54.240.144.0/24|$cidr_2|g" \
| sed "s|mybucket|$mybucket|g" \
| sed "s|session_random|$session_random|g" \
> $output_name
done
```

Grant access to any AWS credentials associated with either account replacing policy.json with
assume-role-for-mybucket.json

```.bash
aws s3api create-bucket --bucket $mybucket
aws s3api put-bucket-policy --bucket $mybucket --policy file://s3-resource-cross-account-policy.json
```

aws s3api get-bucket-policy --bucket $mybucket

aws iam list-attached-user-policies --user-name s3reader

aws --profile pbeta-s3reader s3api put-object --bucket $mybucket --key can-internal-readonly-role-put-object/test1 --body Readme.md

aws --profile pdelta iam create-user --user-name s3tester1-$session_random

aws --profile pdelta iam create-access-key --user-name s3tester1-$session_random
echo "place the aws_access_key_id and aws_secret_access_key in ~/.aws/credentials with profile name [s3tester1-ext]."

aws --profile pdelta iam create-role --role-name s3tester1-role-$session_random --assume-role-policy-document file://assume-role-policy-for-s3tester-extern.json

aws iam create-role --role-name s3reader-$session_random --assume-role-policy file://assume-role-policy-for-s3reader.json

Questions:

1. Can any user 
https://docs.aws.amazon.com/IAM/latest/UserGuide/intro-structure.html
