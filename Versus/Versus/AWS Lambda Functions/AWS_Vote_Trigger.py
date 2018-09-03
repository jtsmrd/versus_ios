# AWS_Vote_Trigger
import boto3
import decimal
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
competitionTable = dynamodb.Table('AWS_Competition')

def lambda_handler(event, context):
    
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            vote = record['dynamodb']['NewImage']
            statusCode = incrementCompetitorVoteCount(vote)
            if statusCode != 200:
                print('Failed to increment vote')
                continue
            
            else: # status code == 200
                continue
        elif record['eventName'] == 'MODIFY':
            vote = record['dynamodb']['NewImage']
            statusCode = switchCompetitorVoteCount(vote)
            if statusCode != 200:
                print('Failed to increment/ decrement vote')
                continue
            
            else: # status code == 200
                continue
    
    
    return 'Successfully processed Vote records'


def incrementCompetitorVoteCount(vote):
    competitionId = vote['competitionId']['S']
    competitor = vote['competitor']['S']
    
    incrementVoteCountProperty = None
    if competitor == 'first':
        incrementVoteCountProperty = 'firstCompetitorVoteCount'
    else:
        incrementVoteCountProperty = 'secondCompetitorVoteCount'

    if incrementVoteCountProperty is not None:
        response = competitionTable.update_item(
            Key={
                'competitionId': competitionId
            },
            UpdateExpression="ADD #incrementVoteCountProperty :val",
            ExpressionAttributeNames={
                '#incrementVoteCountProperty': incrementVoteCountProperty
            },
            ExpressionAttributeValues={
                ':val': decimal.Decimal(1)
            }
        )
        return response['ResponseMetadata']['HTTPStatusCode']
    else:
        return 'Unable to increment vote count. Vote count property null'


def switchCompetitorVoteCount(vote):
    competitionId = vote['competitionId']['S']
    competitor = vote['competitor']['S']
    
    incrementVoteCountProperty = None
    decrementVoteCountProperty = None
    if competitor == 'first':
        incrementVoteCountProperty = 'firstCompetitorVoteCount'
        decrementVoteCountProperty = 'secondCompetitorVoteCount'
    else:
        incrementVoteCountProperty = 'secondCompetitorVoteCount'
        decrementVoteCountProperty = 'firstCompetitorVoteCount'

    if incrementVoteCountProperty is not None and decrementVoteCountProperty is not None:
        response = competitionTable.update_item(
            Key={
                'competitionId': competitionId
            },
            UpdateExpression="ADD #incrementVoteCountProperty :incVal, #decrementVoteCountProperty :decVal",
            ExpressionAttributeNames={
                '#incrementVoteCountProperty': incrementVoteCountProperty,
                '#decrementVoteCountProperty': decrementVoteCountProperty
            },
            ExpressionAttributeValues={
                ':incVal': decimal.Decimal(1),
                ':decVal': decimal.Decimal(-1)
            }
        )
        return response['ResponseMetadata']['HTTPStatusCode']
    else:
        return 'Unable to increment/ decrement vote count. A Vote count property null'
