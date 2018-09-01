# AWS_Follower_Trigger
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
notificationTable = dynamodb.Table('AWS_Notification')

def lambda_handler(event, context):

    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            follower = record['dynamodb']['NewImage']
            statusCode = createNewNotificationRecord(follower)
            if statusCode != 200:
                print('Failed to create Notification record for Follower {}'.format(follower['userId']['S']))
                continue
                    
            else: # status code == 200
                continue
        else: # event != INSERT
            continue


    return 'Successfully processed Follower records'


# Create a new AWS_Notification record for the followed user
def createNewNotificationRecord(follower):
    response = notificationTable.put_item(
        Item={
            'createDate': str(datetime.utcnow().isoformat()+'Z'),
            'notificationInfo': {
                'username': follower['username']['S'],
                'userId': follower['followerUserId']['S'],
                'notificationText': '#username started following you.'
            },
            'notificationId': str(uuid.uuid4()),
            'notificationTypeId': 1,
            'userId': follower['userId']['S'],
            'wasViewed': 0
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']
