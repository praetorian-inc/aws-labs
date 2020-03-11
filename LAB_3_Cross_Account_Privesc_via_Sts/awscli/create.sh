# Set AWS_PROFILE to the app1 account
AWS_PROFILE=pbeta

AWS_PROFILE=${AWS_PROFILE} aws iam create-role --assume-role-policy-document file://app1_global_mon_trust_policy.json --role-name global_app_monito
AWS_PROFILE=${AWS_PROFILE} aws iam put-role-policy --policy-document file://app1_global_mon_inline_policy_put.json --policy-name app1_global_mon_inline --role-name global_app_monitor

