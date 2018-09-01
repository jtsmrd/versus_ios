# AWS_Competition_Trigger
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
notificationTable = dynamodb.Table('AWS_Notification')

def lambda_handler(event, context):
    
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            
            competition = record['dynamodb']['NewImage']
            competitionId = competition['competitionId']['S']
            
            notifyUserId = competition['firstEntryUserId']['S']
            opponentUserId = competition['secondEntryUserId']['S']
            opponentUsername = competition['secondEntryUsername']['S']
            createCompetitionStartNotification(competitionId, notifyUserId, opponentUserId, opponentUsername)
            
            notifyUserId = competition['secondEntryUserId']['S']
            opponentUserId = competition['firstEntryUserId']['S']
            opponentUsername = competition['firstEntryUsername']['S']
            createCompetitionStartNotification(competitionId, notifyUserId, opponentUserId, opponentUsername)
        
        elif record['eventName'] == 'MODIFY':
            
            competition = record['dynamodb']['NewImage']
            competitionId = competition['competitionId']['S']
            
            # if competitionRecord['status']['S'] == 'COMPLETE':
            if attribute_not_exists(competition['competitionIsActive']):
                
                winnerUserId = competition['winnerUserId']['S']
                firstEntryUserId = competition['firstEntryUserId']['S']
                firstEntryUsername = competition['firstEntryUsername']['S']
                secondEntryUserId = competition['secondEntryUserId']['S']
                secondEntryUsername = competition['secondEntryUsername']['S']
                
                winningUsername = None
                losingUsername = None
                losingUserId = None
                if winnerUserId == firstEntryUserId:
                    winningUsername = firstEntryUsername
                    losingUsername = secondEntryUsername
                    losingUserId = secondEntryUserId
                else:
                    winningUsername = secondEntryUsername
                    losingUsername = firstEntryUsername
                    losingUserId = firstEntryUserId
                
                createCompetitionWonNotification(competitionId, winnerUserId, losingUserId, losingUsername)
                createCompetitionLostNotification(competitionId, losingUserId, winnerUserId, winningUsername)
            
            else: # Competition is still active
                continue
        else: # event != INSERT or MODIFY
            continue


    return 'Create Notification records complete'


# Create a Notification record for the winning user
def createCompetitionStartNotification(competitionId, notifyUserId, opponentUserId, opponentUsername):
    response = notificationTable.put_item(
        Item={
            'createDate': str(datetime.utcnow().isoformat()+'Z'),
            'notificationInfo': {
                'userId': opponentUserId,
                'username': opponentUsername,
                'competitionId': competitionId,
                'notificationText': 'Your Competition vs. #username has begun.'
            },
            'notificationTypeId': 3,
            'userId': notifyUserId,
            'wasViewed': 0
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        print('Failed to create competition start Notification record: {}'.format(response))

    return


# Create a Notification record for the winning user
def createCompetitionWonNotification(competitionId, notifyUserId, losingUserId, losingUsername):
    response = notificationTable.put_item(
        Item={
            'createDate': str(datetime.utcnow().isoformat()+'Z'),
            'notificationInfo': {
                'userId': losingUserId,
                'username': losingUsername,
                'competitionId': competitionId,
                'notificationText': 'Congratulations! You won your competition vs. #username.'
            },
            'notificationTypeId': 4,
            'userId': notifyUserId,
            'wasViewed': 0
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        print('Failed to create competition won Notification record: {}'.format(response))

    return


# Create a Notification record for the losing user
def createCompetitionLostNotification(competitionId, notifyUserId, winnerUserId, winningUsername):
    response = notificationTable.put_item(
        Item={
            'createDate': str(datetime.utcnow().isoformat()+'Z'),
            'notificationInfo': {
                'userId': winnerUserId,
                'username': winningUsername,
                'competitionId': competitionId,
                'notificationText': 'You lost your competition vs. #username. Better luck next time!'
            },
            'notificationTypeId': 5,
            'userId': notifyUserId,
            'wasViewed': 0
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] != 200:
        print('Failed to create competition lost Notification record: {}'.format(response))

    return
