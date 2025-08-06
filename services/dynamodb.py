# Charlie Lees
# Uses BOTO3 to interface with dynamodb


import boto3

dynamo = boto3.resource(
    "dynamodb",
    region_name="us-east-1",
)

dynamo_client = boto3.client(
    "dynamodb",
    region_name="us-east-1",
)

table_name = "user-data"

table = dynamo.Table(table_name)

# Healthcheck


def healthcheck():
    try:
        table.load()
        return "healthy"
    except:
        return ""


# Backup


def backup():
    #backup = dynamo_client.create_backup(TableName=table_name, BackupName="backup")
    print("backing up")
    backup = table.scan()['Items']
    return backup


#######
# GET #
#######


def get_layout(user_id: str):
    layout = table.get_item(Key={"user_id": user_id})
    return layout["Item"]


############
# POST/PUT #
############

def alter_layout(layout: dict):
    table.put_item(Item=layout)


##########
# DELETE #
##########


def delete_layout(user_id: str):
    layout = table.delete_item(Key={"user_id": f"{user_id}"}, ReturnValues="ALL_OLD")
    return layout
