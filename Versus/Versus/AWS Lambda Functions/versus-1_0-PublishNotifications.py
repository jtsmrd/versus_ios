# versus-1_0-PublishNotifications
import boto3
import uuid
import json
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
sns = boto3.client('sns')
userSNSEndpointARNTable = dynamodb.Table('versus-mobilehub-387870640-AWS_UserSNSEndpointARN')

def lambda_handler(event, context):
    print('Notification Event: {}'.format(event))
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            notificationRecord = record['dynamodb']['NewImage']
            notifyUserPoolUserId = notificationRecord['notifyUserPoolUserId']['S']

            notifyUserSNSEndpointARN = getUserSNSEndpointARN(notifyUserPoolUserId)

            if notifyUserSNSEndpointARN is not None:
                tryPublishNotification(notifyUserSNSEndpointARN, notificationRecord)
                continue
            else:
                continue
        else:
            continue

    return 'Finished processing Notification records'


# Get the SNS Endpoint ARN for the given userPoolUserId for notifications (if one exists).
def getUserSNSEndpointARN(userPoolUserId):
    response = userSNSEndpointARNTable.get_item(
        #TableName='versus-mobilehub-387870640-AWS_UserSNSEndpointARN',
        Key={
            'userPoolUserId': userPoolUserId
        }
    )
    userSNSEndpointARN = None
    try:
        userSNSEndpointARN = response['Item']['endpointArn']
    except Exception as e:
        print('User SNS Endpoint ARN does not exist for {}'.format(userPoolUserId))
        pass
    return userSNSEndpointARN


# Attempt to publish notification for Notification record
def tryPublishNotification(notifyUserSNSEndpointARN, notificationRecord):
    notificationType = int(notificationRecord['notificationTypeId']['N'])
    alertMessage = None

    if notificationType == 1:
        # New Follower
        followerNotificationInfo = notificationRecord['notificationInfo']['M']
        followerUsername = followerNotificationInfo['followerUsername']['S']
        notificationText = followerNotificationInfo['notificationText']['S']
        # '#username started following you.'
        alertMessage = notificationText.replace('#username', '@' + followerUsername)

    elif notificationType == 2:
        # User ranked up
        # NOT IMPLEMENTED
        return
    elif notificationType == 3:
        # Competition started
        competitionNotificationInfo = notificationRecord['notificationInfo']['M']
        opponentUsername = competitionNotificationInfo['username']['S']
        notificationText = competitionNotificationInfo['notificationText']['S']
        # 'Your Competition vs. #username has begun.'
        alertMessage = notificationText.replace('#username', '@' + opponentUsername)

    elif notificationType == 4:
        # Competition won
        competitionWonNotificationInfo = notificationRecord['notificationInfo']['M']
        opponentUsername = competitionWonNotificationInfo['username']['S']
        notificationText = competitionWonNotificationInfo['notificationText']['S']
        # 'Congratulations! You won your competition vs. #username.'
        alertMessage = notificationText.replace('#username', '@' + opponentUsername)

    elif notificationType == 5:
        # Competition lost
        competitionLostNotificationInfo = notificationRecord['notificationInfo']['M']
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
