# versus-1_0-GetFollowedUserCompetitions
import boto3
import json
import decimal
from datetime import datetime
from datetime import timedelta
from boto3.dynamodb.conditions import Key, Attr

# Helper class to convert a DynamoDB item to JSON.
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if abs(o) % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)

dynamodb = boto3.resource('dynamodb')
competitionTable = dynamodb.Table('versus-mobilehub-387870640-AWS_Competition')

def lambda_handler(event, context):
    print('My event: {}'.format(event))
    followedUserIds = event['followedUserIds']
    response = getFollowedUserCompetitions(followedUserIds)
    #return json.dumps(response, indent=1, cls=DecimalEncoder)
    return response

def getFollowedUserCompetitions(followedUserIds):
    response = competitionTable.scan(
        FilterExpression=Attr('user1userPoolUserId').is_in(followedUserIds) | Attr('user2userPoolUserId').is_in(followedUserIds)
    )
    return response
