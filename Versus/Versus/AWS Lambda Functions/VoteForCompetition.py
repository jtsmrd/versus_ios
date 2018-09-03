# VoteForCompetition
import boto3
import decimal
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
competitionTable = dynamodb.Table('AWS_Competition')
voteTable = dynamodb.Table('AWS_Vote')
userTable = dynamodb.Table('AWS_User')

def lambda_handler(event, context):

    voteInfo = event['voteInfo']
    competitionId = voteInfo['competitionId']
    userId = voteInfo['userId']
    competitionEntryId = voteInfo['competitionEntryId']
    competitor = voteInfo['competitor']
    isVoteSwitch = int(voteInfo['voteSwitch'])

    voteStatusCode = createOrUpdateVote(competitionId, userId, competitionEntryId, competitor)
    if voteStatusCode == 200:

        incrementProperty = None
        decrementProperty = None
        if competitor == 'first':
            incrementProperty = 'firstCompetitorVoteCount'
            decrementProperty = 'secondCompetitorVoteCount'
        else:
            incrementProperty = 'secondCompetitorVoteCount'
            decrementProperty = 'firstCompetitorVoteCount'

        if isVoteSwitch == 1:
            competitionStatusCode = switchCompetitionVote(competitionId, incrementProperty, decrementProperty)
        else:
            competitionStatusCode = incrementCompetitionVote(competitionId, incrementProperty)

            userStatusCode = updateUserVoteCount(userId)
            if userStatusCode != 200:
                print('Failed to update user vote count')

        if competitionStatusCode == 200:
            return 'Success'

        else:
            return 'Failed to update competition vote'

    else:
        return 'Failed to create vote'


def createOrUpdateVote(competitionId, userId, competitionEntryId, competitor):
    competitionIdUserId = '{}|{}'.format(competitionId, userId)
    response = voteTable.update_item(
        Key={
            'competitionIdUserId': competitionIdUserId
        },
        UpdateExpression="""SET competitionId = :competitionId,
                                competitionEntryId = :competitionEntryId,
                                competitor = :competitor""",
        ExpressionAttributeValues={
            ':competitionId': competitionId,
            ':competitionEntryId': competitionEntryId,
            ':competitor': competitor
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


def incrementCompetitionVote(competitionId, incrementProperty):
    response = competitionTable.update_item(
        Key={
            'competitionId': competitionId
        },
        UpdateExpression="ADD #incrementProperty :incVal",
        ExpressionAttributeNames={
            '#incrementProperty': incrementProperty
        },
        ExpressionAttributeValues={
            ':incVal': decimal.Decimal(1)
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


def switchCompetitionVote(competitionId, incrementProperty, decrementProperty):
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


def updateUserVoteCount(userId):
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
