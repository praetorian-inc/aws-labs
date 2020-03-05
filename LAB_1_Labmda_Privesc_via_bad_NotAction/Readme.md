# LAB_1_Lambda_Power_Users


## Part I: Diagnosing and Exploiting the Problem

This lab examines a real-word issue discovered on a cloud pen test.
Devops had wanted to restrict the marketing team from privilege escalation by disallowing `iam:*` actions.

The policy they used was as follows:

        {
            "Arn": "arn:aws:iam::111111111111:group/PowerUsers-marketing-group",
            "AttachedManagedPolicies": [
                {
                    "PolicyArn": "arn:aws:iam::aws:policy/AWSLambdaFullAccess",
                    "PolicyName": "AWSLambdaFullAccess"
                }
            ],
            "CreateDate": "2012-12-20T16:20:10+00:00",
            "GroupId": "AGPAJNZACMXXXXXXXXXX",
            "GroupName": "owerUsers-marketing-group",
            "GroupPolicyList": [
                {
                    "PolicyDocument": {
                        "Statement": [
                            {
                                "Effect": "Allow",
                                "NotAction": "iam:*",
                                "Resource": "*"
                            }
                        ]
                    },
                    "PolicyName": "PowerUserAccess-marketing-2012122000000"
                }
            ],
            "Path": "/"
        }

Notice the NotAction in the PolicyDocument. 
* What is this trying to do? 
* What does it actually do?

See the answer in [Answers/Readme_Theory.md](Answers/Readme_Theory.md)


We will explore this with a scenario where an attaker has obtained the credentials to a user `marketing-dave`.
who is part of the PowerUsers-marketing-group. We will demonstrate how the policy above can be abused to
create a lambda function with a high-privileged role to elevate dave's own privileges.


1. Using admin creds, Create the roles and policies to simulate discovered high-privilege 

    ./setup.sh

2. Explore your own AWS account to discover high-privileged roles that might be used in your account.
   ./recon.sh

3. Using dave's credentials, create the lambda function using the `discovered_role_with_iam_privs` role
   ./kingme.sh


## Part II: Fixing the Problem (WIP)

Now comes the hard part. How do we accomplish what the Devops team had intended? Allow the marketing power users as
much freedom as possible (at least as much control over Lambda as possible) without giving them a path to privilege escalate to Admin?

### Options

* Permissions Boundary
* Explicit Deny
* Whitelist Passrole Resources
* Separate AWS account where marketing is admin + CI/CD to publish into existing account



## TODO

* Change the group privileges to only allow assume-role and push all privs into that group role, following best practices.
* Replace all hard-coded random sequences with $RANDOM or similar.
* Develop the "How to Fix" options.
* Add cleanup instrutions.
