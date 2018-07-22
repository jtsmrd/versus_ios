# versus-1_0-CreateNewFollowerNotification
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
notificationTable = dynamodb.Table('versus-mobilehub-387870640-AWS_Notification')

def lambda_handler(event, context):

    for record in event['Records']:
        if record['eventName'] == 'INSERT':

            followerRecord = record['dynamodb']['NewImage']
            userPoolUserId = followerRecord['followedUserId']['S']

            notificationCreatedSuccessfully = createNotification(followerRecord, userPoolUserId)
            if notificationCreatedSuccessfully == False:
                print('Failed to create Notification record for Follower {}'.format(followerRecord['id']['S']))
            continue
        else:
            continue

    return 'Successfully processed Follower records'


def createNotification(followerRecord, notifyUserPoolUserId):
    notificationDate = str(datetime.utcnow().isoformat()+'Z')

    response = notificationTable.put_item(
        Item={
            'createDate': notificationDate,
            'notificationInfo': {
                'followerUsername': followerRecord['followerUsername']['S'],
                'followerUserPoolUserId': followerRecord['followerUserId']['S'],
                'notificationText': '#username started following you.'
            },
            'notificationTypeId': 1,
            'notifyUserPoolUserId': notifyUserPoolUserId,
            'wasViewed': 0
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('Notification record created successfully')
        return True
    else:
        print('Failed to create Notification record: {}'.format(response))
        return False
