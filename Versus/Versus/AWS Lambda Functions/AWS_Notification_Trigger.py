# AWS_Notification_Trigger
import boto3
import uuid
import json
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
userSNSEndpointARNTable = dynamodb.Table('AWS_UserSNSEndpointARN')

def lambda_handler(event, context):
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            notification = record['dynamodb']['NewImage']
            userId = notification['userId']['S']

            notifyUserSNSEndpointARN = getUserSNSEndpointARN(userId)

            if notifyUserSNSEndpointARN is not None:
                tryPublishNotification(notifyUserSNSEndpointARN, notification)
                continue
            
            else: # notifyUserSNSEndpointARN is None
                continue
        else: # event != INSERT
            continue


    return 'Finished processing Notification records'


# Get the SNS Endpoint ARN for the given userId for notifications (if one exists).
def getUserSNSEndpointARN(userId):
    response = userSNSEndpointARNTable.get_item(
        Key={
            'userId': userId
        }
    )
    userSNSEndpointARN = None
    try:
        userSNSEndpointARN = response['Item']['endpointArn']
    except Exception as e:
        print('User SNS Endpoint ARN does not exist for {}'.format(userId))
        pass
    return userSNSEndpointARN


# Attempt to publish notification for Notification record
def tryPublishNotification(notifyUserSNSEndpointARN, notification):
    notificationType = int(notification['notificationTypeId']['N'])
    alertMessage = None

    if notificationType == 1:
        # New Follower
        followerNotificationInfo = notification['notificationInfo']['M']
        username = followerNotificationInfo['username']['S']
        notificationText = followerNotificationInfo['notificationText']['S']
        # '#username started following you.'
        alertMessage = notificationText.replace('#username', '@' + username)

    elif notificationType == 2:
        # User ranked up
        # NOT IMPLEMENTED
        return
    elif notificationType == 3:
        # Competition started
        competitionNotificationInfo = notification['notificationInfo']['M']
        opponentUsername = competitionNotificationInfo['username']['S']
        notificationText = competitionNotificationInfo['notificationText']['S']
        # 'Your Competition vs. #username has begun.'
        alertMessage = notificationText.replace('#username', '@' + opponentUsername)

    elif notificationType == 4:
        # Competition won
        competitionWonNotificationInfo = notification['notificationInfo']['M']
        opponentUsername = competitionWonNotificationInfo['username']['S']
        notificationText = competitionWonNotificationInfo['notificationText']['S']
        # 'Congratulations! You won your competition vs. #username.'
        alertMessage = notificationText.replace('#username', '@' + opponentUsername)

    elif notificationType == 5:
        # Competition lost
        competitionLostNotificationInfo = notification['notificationInfo']['M']
        opponentUsername = competitionLostNotificationInfo['username']['S']
        notificationText = competitionLostNotificationInfo['notificationText']['S']
        # 'You lost your competition vs. #username. Better luck next time!'
        alertMessage = notificationText.replace('#username', '@' + opponentUsername)

    elif notificationType == 6:
        # Competition comment
        # NOT IMPLEMENTED
        return
    elif notificationType == 7:
        # Competition removed
        # NOT IMPLEMENTED
        return
    else:
        return

    message={'aps': {
                'alert': alertMessage,
                'sound': 'default',
                'badge': 1
            }
    }
    jsonMessage = json.dumps(message)
    #Change this for Prod?
    finalMessage = {"APNS_SANDBOX": jsonMessage}

    try:
        sns.publish(
            TargetArn=notifyUserSNSEndpointARN,
            Message=json.dumps(finalMessage),
            MessageStructure='json'
        )
    except Exception as e:
        print('Could not publish winning user notification: {}'.format(e))
        pass
    return
