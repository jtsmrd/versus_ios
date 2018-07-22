# versus-1_0-CreateCompetitionNotifications
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
notificationTable = dynamodb.Table('versus-mobilehub-387870640-AWS_Notification')

def lambda_handler(event, context):
    print('Competition event: {}'.format(event))
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            competitionRecord = record['dynamodb']['NewImage']
            createCompetitionStartNotificationForUserPoolUserId(competitionRecord['user1userPoolUserId']['S'], competitionRecord)
            createCompetitionStartNotificationForUserPoolUserId(competitionRecord['user2userPoolUserId']['S'], competitionRecord)
        elif record['eventName'] == 'MODIFY':
            competitionRecord = record['dynamodb']['NewImage']
            if competitionRecord['status']['S'] == 'COMPLETE':
                createNotificationForWinningUser(competitionRecord)
                createNotificationForLosingUser(competitionRecord)
            else:
                continue
        else:
            continue


    return 'Create Notification records complete'


# Create a Notification record for the winning user
def createCompetitionStartNotificationForUserPoolUserId(notifyUserPoolUserId, competitionRecord):
    notificationDate = str(datetime.utcnow().isoformat()+'Z')

    competitionId = competitionRecord['id']['S']
    opponentUserPoolUserId = None
    opponentUsername = None

    if notifyUserPoolUserId == competitionRecord['user1userPoolUserId']['S']:
        opponentUserPoolUserId = competitionRecord['user2userPoolUserId']['S']
        opponentUsername = competitionRecord['user2Username']['S']
    else:
        opponentUserPoolUserId = competitionRecord['user1userPoolUserId']['S']
        opponentUsername = competitionRecord['user1Username']['S']

    response = notificationTable.put_item(
        Item={
            'createDate': notificationDate,
            'notificationInfo': {
                'userPoolUserId': opponentUserPoolUserId,
                'username': opponentUsername,
                'competitionId': competitionId,
                'notificationText': 'Your Competition vs. #username has begun.'
            },
            'notificationTypeId': 3,
            'notifyUserPoolUserId': notifyUserPoolUserId,
            'wasViewed': 0
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('Competition started Notification record created successfully')
    else:
        print('Failed to create competition start Notification record: {}'.format(response))

    return


# Create a Notification record for the winning user
def createNotificationForWinningUser(competitionRecord):
    notificationDate = str(datetime.utcnow().isoformat()+'Z')

    winningUserPoolUserId = competitionRecord['winningUserPoolUserId']['S']
    competitionId = competitionRecord['id']['S']
    losingUserPoolUserId = None
    losingUserUsername = None

    if winningUserPoolUserId == competitionRecord['user1userPoolUserId']['S']:
        losingUserPoolUserId = competitionRecord['user2userPoolUserId']['S']
        losingUserUsername = competitionRecord['user2Username']['S']
    else:
        losingUserPoolUserId = competitionRecord['user1userPoolUserId']['S']
        losingUserUsername = competitionRecord['user1Username']['S']

    response = notificationTable.put_item(
        Item={
            'createDate': notificationDate,
            'notificationInfo': {
                'userPoolUserId': losingUserPoolUserId,
                'username': losingUserUsername,
                'competitionId': competitionId,
                'notificationText': 'Congratulations! You won your competition vs. #username.'
            },
            'notificationTypeId': 4,
            'notifyUserPoolUserId': winningUserPoolUserId,
            'wasViewed': 0
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('Competition won Notification record created successfully')
    else:
        print('Failed to create competition won Notification record: {}'.format(response))

    return


# Create a Notification record for the losing user
def createNotificationForLosingUser(competitionRecord):
    notificationDate = str(datetime.utcnow().isoformat()+'Z')

    winningUserPoolUserId = competitionRecord['winningUserPoolUserId']['S']
    competitionId = competitionRecord['id']['S']
    losingUserPoolUserId = None
    winningUserUsername = None

    if winningUserPoolUserId == competitionRecord['user1userPoolUserId']['S']:
        losingUserPoolUserId = competitionRecord['user2userPoolUserId']['S']
        winningUserUsername = competitionRecord['user1Username']['S']
    else:
        losingUserPoolUserId = competitionRecord['user1userPoolUserId']['S']
        winningUserUsername = competitionRecord['user2Username']['S']

    response = notificationTable.put_item(
        Item={
            'createDate': notificationDate,
            'notificationInfo': {
                'userPoolUserId': winningUserPoolUserId,
                'username': winningUserUsername,
                'competitionId': competitionId,
                'notificationText': 'You lost your competition vs. #username. Better luck next time!'
            },
            'notificationTypeId': 5,
            'notifyUserPoolUserId': losingUserPoolUserId,
            'wasViewed': 0
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('Competition lost Notification record created successfully')
    else:
        print('Failed to create competition lost Notification record: {}'.format(response))

    return
