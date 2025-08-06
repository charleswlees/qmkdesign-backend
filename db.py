# Charlie Lees
# This file contains methods pulling together functionality from both the s3 and dynamo services.

from services import s3, dynamodb
from datetime import date


# Verifies both resources are online
def healthcheck():
    try:
        dbhc = dynamodb.healthcheck()
        s3hc = s3.healthcheck()
        if dbhc == "healthy" and s3hc == "healthy":
            return "healthy"
        else:
            return ""
    except:
        return ""


def backup_check(backup_present):
    # Only backup on Sunday; when it hasn't been done already
    if date.today().weekday() != 6:
        return False
    if backup_present == False and date.today().weekday() == 6:
        backup()
        return True


# Backup dynamo state to s3 bucket
def backup():
    try:
        backup = dynamodb.backup()
        s3.add_backup(backup)
    except Exception as e:
        print("Error creating backup and sending to s3", e)
        return None


# Returns output from GET using the DynanoDB results
def get_layout(user_id):
    try:
        output = dynamodb.get_layout(user_id)
        return output
    except:
        return ""


# alter / add recipe, works for both PUT and PUSH
def alter_layout(layout):

    try:
        dynamodb.alter_layout(layout)
        return get_layout(layout["user_id"])
    except Exception as e:
        print("Error altering layout", e)
        return ""


# Deletes given recipe, no return
def delete_layout(user_id):
    try:
        #user_id = layout["user_id"]
        output = dynamodb.delete_layout(user_id)
        return output
    except:
        return ""
