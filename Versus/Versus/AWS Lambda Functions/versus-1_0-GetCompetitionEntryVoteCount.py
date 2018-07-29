# versus-1_0-GetCompetitionEntryVoteCount
import boto3
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
competitionVoteTable = dynamodb.Table('versus-mobilehub-387870640-AWS_CompetitionVote')

def lambda_handler(event, context):
    
    competitionEntryId = event['competitionEntryId']
    voteCount = getVoteCountFor(competitionEntryId)
    return voteCount

def getVoteCountFor(competitionEntryId):
    response = competitionVoteTable.query(
        IndexName="competitionEntryIdIndex",
        KeyConditionExpression=Key('competitionEntryId').eq(competitionEntryId),
        Select="COUNT"
    )
    
    return response['Count']
