/* Terraform's aws_iam_role_policy module creates an 
inline policy and attaches it to a new role.

To learn more about the policy nouns (trust policy,
inline and managed permissions policies) run
> aws iam put-policy-role help

For an overview of trust policy abuse see
https://summitroute.com/blog/2019/02/04/lateral_movement_abusing_trust/

In this scenario, the architect's intention was to have
one central tool assume roles in all the accounts in order
to collect and aggregate data across the enterprise,
as well as some other operational tasks.
Any time we need to extend its functionality, manually
updating the role in ~40 accounts (and growing) is a
laborious task. So we allow the central account role
to update the policy.

The intended capabilities of the role are in the
attached managed policy - custom_READONLY. The 
inline policy was to facilitate updates only.

Unfortunately, the iam:PutPolicyRole is equivalent to
admin so this means that the maintenance workaround
changed the role which should have been a custom readonly
to an admin.

We set up the scenario where
111111-111111 app1 account with global_app_monitor role
222222-222222 app2 account with global_app_monitor role
000000-000000 core account which assumes a role in all app 
accounts using the core_app_monitor role.
*/
provider "aws" {
  region  = "us-east-1"
}

resource "aws_iam_role_policy" "global_app_monitor" {
  name = "global_app_monitor"
  role = "${aws_iam_role.global_app_monitor.id}"

/* The inline policy which allows the update to global_app_monitor.
The iam::*:role/ means that any account which trusts
this role arn:aws:iam::111111111111:role/global_app_monitor
can will allow it to update the policy. 

This means that if any one app account were compromised,
through its global_app_mon role, all other accounts would be compromised.

*/

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sts:PutIamPolicy"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:iam::*:role/global_app_monitor"
    }
  ]
}
EOF
}

/* assume_role_policy is the
- Role Trust Policy from Scout.
- Trust Relationship from the AWS console
- trusted or assume policy

This says which principals can assume this
role. 
*/

resource "aws_iam_role" "global_app_monitor" {

  assume_role_policy = <<EOF
{
"Statement":  [
{
  "Action": [
    "sts:AssumeRole"
  ],
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::000000000000:role/core_app_monitor"
  },
  "Sid": ""
}
  ] ,
  "Version":  "2012-10-17"

}
EOF

}