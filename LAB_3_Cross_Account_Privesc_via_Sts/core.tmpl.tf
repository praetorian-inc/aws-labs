
provider "aws" {
  region  = "us-east-1"
}

resource "aws_iam_role" "core_app_monitor" {
  name = "core_app_monitor"

  assume_role_policy = <<EOF
{
"Statement":  [
{
  "Action": [
    "sts:AssumeRole"
  ],
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::000000000000:user/core_monitor"
  },
  "Sid": ""
}
  ] ,
  "Version":  "2012-10-17"

}
EOF
}

# Inline policy
resource "aws_iam_role_policy" "update_app_mon_role_policy" {
  name = "AllowCoreToAssumeGlobalAppMon"
  role = "${aws_iam_role.core_app_monitor.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::*:role/global_app_monitor",
      "Effect": "Allow",
      "Sid": "AllowCoreToAssumeGlobalAppMon"
    }
  ]
}
EOF
}
resource "aws_iam_user" "core_monitor" {
  name = "core_monitor"

  tags = {
    tag-key = "x-accout-testing"
  }
}

resource "aws_iam_access_key" "core_mon_key" {
  user    = "${aws_iam_user.core_monitor.name}"
}

resource "aws_iam_user_policy" "core_monitor_inline_policy" {
  name = "test"
  user = "${aws_iam_user.core_monitor.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:AssumeRole"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:iam::000000000000:role/core_app_monitor"
    }
  ]
}
EOF
}

output "secret" {
  value = "${aws_iam_access_key.core_mon_key.encrypted_secret}"
}
