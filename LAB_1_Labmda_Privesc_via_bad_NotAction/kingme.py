import boto3

def handler(event, context):
  result = ""
  try:
    client = boto3.client("iam")
    result = client.attach_user_policy(
      UserName='marketing-dave',
      PolicyArn='arn:aws:iam::aws:policy/AdministratorAccess'
    )
  except Exception as e:
    print(e)
  return {
    'statusCode': 200,
    'body': result
  }
