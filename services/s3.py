# Charlie Lees
# CS 6620
# Uses BOTO3 to interface with s3


import boto3
import json
from datetime import date
import decimal

s3 = boto3.resource(
    "s3",
    aws_access_key_id="test",
    aws_secret_access_key="test",
    endpoint_url="http://localstack:4566",
    #endpoint_url="http://localhost:4566",
)

bucket = s3.Bucket("backup-bucket")

# response = s3.list_buckets()
# print(response)


def healthcheck():
    try:
        bucket.load()
        return "healthy"
    except:
        return ""


#######
# GET #
#######


def get_backup(backup_date: date):
    formatted_date = backup_date.strftime("%Y%m%d")
    backup_obj = bucket.Object(f"backups/{formatted_date}.json")
    backup = backup_obj.get()["Body"].read().decode("utf-8")
    return backup


############
# POST/PUT #
############

# Example Input
# {
#   keyboard_layout: { ... keyboard state go here ... },
#   user_id: user_id go here,
#   keyboard_name: keyboard name go here
# }

# Found this function code here: https://github.com/boto/boto3/issues/369#issuecomment-157205696
# Just had to convert it to work w/ Python3 (xrange -> range, iterkeys -> keys)
def replace_decimals(obj):
    if isinstance(obj, list):
        for i in range(len(obj)):
            obj[i] = replace_decimals(obj[i])
        return obj
    elif isinstance(obj, dict):
        for k in obj.keys():
            obj[k] = replace_decimals(obj[k])
        return obj
    elif isinstance(obj, decimal.Decimal):
        if obj % 1 == 0:
            return int(obj)
        else:
            return float(obj)
    else:
        return obj

def add_backup(backup: dict):
    backup_json = json.dumps(replace_decimals(backup), indent=4)
    bucket.put_object(
        Key=f'backups/{date.today().strftime("%Y%m%d")}.json',
        Body=backup_json,
        ContentType="application/json",
    )

##########
# DELETE #
##########

def delete_backup(backup_date: date):
    formatted_date = backup_date.strftime("%Y%m%d")
    layout_obj = bucket.Object(f"backups/{formatted_date}.json")
    layout_obj.delete()


