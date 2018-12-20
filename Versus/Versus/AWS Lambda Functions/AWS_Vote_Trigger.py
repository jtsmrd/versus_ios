# AWS_Vote_Trigger
import boto3
import decimal
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
competitionTable = dynamodb.Table('AWS_Competition')
userTable = dynamodb.Table('AWS_User')

def lambda_handler(event, context):

    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            vote = record['dynamodb']['NewImage']

            updateCompetitionStatusCode = incrementCompetitorVoteCount(vote)
            if updateCompetitionStatusCode != 200:
                print('Failed to increment vote')

            updateUserTotalVotes = updateUserVoteCount(vote)
            if updateUserTotalVotes != 200:
                print('Failed to increment user total votes')

        elif record['eventName'] == 'MODIFY':
            vote = record['dynamodb']['NewImage']
            statusCode = switchCompetitorVoteCount(vote)
            if statusCode != 200:
                print('Failed to increment/ decrement vote')


    return 'Successfully processed Vote records'


def updateUserVoteCount(vote):
    competitionIdUserId = vote['competitionIdUserId']['S']
    competitionId = vote['competitionId']['S']
    userId = competitionIdUserId.replace(competitionId, "")
    response = userTable.update_item(
        Key={
            'userId': userId
        },
        UpdateExpression="ADD totalTimesVoted :val",
        ExpressionAttributeValues={
            ':val': decimal.Decimal(1)
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


def incrementCompetitorVoteCount(vote):
    competitionId = vote['competitionId']['S']
    competitor = vote['competitor']['S']

    incrementProperty = None
    if competitor == 'first':
        incrementProperty = 'firstCompetitorVoteCount'
    else:
        incrementProperty = 'secondCompetitorVoteCount'

    if incrementProperty is not None:
        response = competitionTable.update_item(
            Key={
                'competitionId': competitionId
            },
            UpdateExpression="ADD #incrementProperty :val",
            ExpressionAttributeNames={
                '#incrementProperty': incrementProperty
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

    incrementProperty = None
    decrementProperty = None
    if competitor == 'first':
        incrementProperty = 'firstCompetitorVoteCount'
        decrementProperty = 'secondCompetitorVoteCount'
    else:
        incrementProperty = 'secondCompetitorVoteCount'
        decrementProperty = 'firstCompetitorVoteCount'

    if incrementProperty is not None and decrementProperty is not None:
        response = competitionTable.update_item(
            Key={
                'competitionId': competitionId
            },
            UpdateExpression="ADD #incrementProperty :incVal, #decrementProperty :decVal",
            ExpressionAttributeNames={
                '#incrementProperty': incrementProperty,
                '#decrementProperty': decrementProperty
            },
            ExpressionAttributeValues={
                ':incVal': decimal.Decimal(1),
                ':decVal': decimal.Decimal(-1)
            }
        )
        return response['ResponseMetadata']['HTTPStatusCode']
    else:
        return 'Unable to increment/ decrement vote count. A Vote count property null'
