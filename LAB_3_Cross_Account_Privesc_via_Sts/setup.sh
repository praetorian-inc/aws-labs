AWS_CORE_ACCOUNT=057011330707
AWS_APP1_ACCOUNT=279038159887
# The app resources are same for all app1,2... they only explicity
# reference the core account and are created with AWS_PROFILE=<account_profile>
# prefixing the terraform apply.
sed "s/000000000000/${AWS_CORE_ACCOUNT}/g" app.tmpl.tf > app1/main.tf
sed "s/000000000000/${AWS_CORE_ACCOUNT}/g" core.tmpl.tf > core/main.tf

