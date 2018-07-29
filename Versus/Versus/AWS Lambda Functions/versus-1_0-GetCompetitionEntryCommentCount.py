# versus-1_0-GetCompetitionEntryCommentCount
import boto3
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
commentTable = dynamodb.Table('versus-mobilehub-387870640-AWS_Comment')

def lambda_handler(event, context):

    competitionEntryId = event['competitionEntryId']
    commentsCount = getCommentCountFor(competitionEntryId)
    return commentsCount

def getCommentCountFor(competitionEntryId):
    response = commentTable.query(
        KeyConditionExpression=Key('competitionEntryId').eq(competitionEntryId),
        Select="COUNT"
    )
    return response['Count']
