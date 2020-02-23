# What's going on?


## What did this policy try to do?


Answer: It was attempting to prevent any iam actions.

## What did it actually do?

Answer: It allowed any action over all 200+ possible action groups (lambda, cloudformation, ec2, ...) except iam.

* It did not deny anything
* If you add (Allow,NotAction,iam*) to (Allow,Action,iam*) you get (Allow,Action,*) = Admin. This is because (Allow, NotAction, iam:*)
expands to (Allow, Action, all-actions-except-iam).

[AWS NotAction](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements_notaction.html) with "Effect: Allow" can be used to shorten the permission  of allowed
actions, but it cannot be used to deny any actions. The documentation doesn't make that crystal clear, but our lab does.


Our marketing group policies include an inline policy and an attached managed policy. The inline policy is below.

```
{
  "Version": "2012-10-17",
  "Statement": [ {
     "Effect": "Allow",
     "NotAction": "iam:*",
     "Resource": ["*"]
    }]
}
```

The attached policy is `arn:aws:iam::aws:policy/AWSLambdaFullAccess` which is managed by AWS and has permissions as follows (skipping the step
of listing the versions with `aws iam list-policy-versions --policy-arn`).

```
aws iam get-policy-version  --policy-arn arn:aws:iam::aws:policy/AWSLambdaFullAccess --version-id v8
```

The result is a bit lengthy, but it a snipped version is
```
{
    "PolicyVersion": {
        "Document": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "cloudformation:DescribeChangeSet",
                        "cloudwatch:*",
                        "cognito-identity:ListIdentityPools",
                        "dynamodb:*",
                        "ec2:DescribeVpcs",
                        "events:*",
                        "iam:GetRole",
                        "iam:PassRole",
                        "iot:AttachPrincipalPolicy",
                        "kinesis:ListStreams",
                        "kms:ListAliases",
                        "lambda:*",
                        "logs:*",
                        "s3:*",
                        "sns:ListTopics",
                        "sqs:ListQueues",
                        "xray:PutTraceSegments"
                    ],
                    "Resource": "*"
                }
            ]
        },
        "VersionId": "v8",
        "IsDefaultVersion": true,
        "CreateDate": "2017-11-27T23:22:38Z"
    }
}
```
The important Action being "iam:Passrole" acting on Resource "*". This was excluded from the incline policy, but included in the AWSLambdaFullAccess managed policy.
This is called the wildcard passrole privilege escalation, as it allows the attacker to pass any high privilege role to EC2, Lambda, etc and then execute the role.

What is worse, is that there is even a problem if the user only has lambda:Invoke and lambda:Update* and no iam:Passrole if there exists a Lambda with 

* `iam:Put*`
* `iam:Attach*`
* `iam:Update*`

Preventing such privilege escalations will require Condition blocks for PassRole actions and carefully restricting Lambda roles to minimal privileges.




