# versus-1_0-CreateCompetition
import boto3
import uuid
from datetime import datetime
from datetime import timedelta
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
competitionEntryTable = dynamodb.Table('versus-mobilehub-387870640-AWS_CompetitionEntry')
competitionTable = dynamodb.Table('versus-mobilehub-387870640-AWS_Competition')

def lambda_handler(event, context):

    unmatchedCompetitionEntryRecords = getUnmatchedCompetitionEntryRecords()

    if unmatchedCompetitionEntryRecords is not None:

        for competitionEntryRecord in unmatchedCompetitionEntryRecords:

            # Query for a matching CompetitionEntry
            competitionEntryMatch = getCompetitionEntryMatch(competitionEntryRecord)
            if competitionEntryMatch is not None:

                # Create Competition record
                competitionCreatedSuccessfully = createCompetition(competitionEntryRecord, competitionEntryMatch)
                if competitionCreatedSuccessfully == True:

                    # Update CompetitionEntry record statuses
                    updatedCompetitionEntryRecordSuccessfully = updateCompetitionEntryMatchStatus(competitionEntryRecord['id'])
                    updatedCompetitionEntryMatchSuccessfully = updateCompetitionEntryMatchStatus(competitionEntryMatch['id'])

                    if updatedCompetitionEntryRecordSuccessfully == True and updatedCompetitionEntryMatchSuccessfully == True:
                        print('Successfully created competition and updated competition entries')
                    else:
                        print('Failed to update competition entries')
                else:
                    continue
            else:
                continue
        return 'Finished processing CompetitionEntry records'

    else:
        return 'No UNMATCHED CompetitionEntry records to process'


# Query the database for CompetitionEntry records that aren't matched.
def getUnmatchedCompetitionEntryRecords():
    response = competitionEntryTable.query(
        IndexName="matchStatusIndex",
        KeyConditionExpression=Key('matchStatus').eq('NOTMATCHED')
    )
    unmatchedCompetitionEntryRecords = response['Items']
    if len(unmatchedCompetitionEntryRecords) > 0:
        return unmatchedCompetitionEntryRecords
    else:
        return None


# Query for CompetitionEntry records that are not matched, doesn't belong to the same user,
# is of the same competition type, and same category.
def getCompetitionEntryMatch(competitionEntryRecord):
    userPoolUserId = competitionEntryRecord['userPoolUserId']
    competitionTypeId = int(competitionEntryRecord['competitionTypeId'])
    categoryId = int(competitionEntryRecord['categoryId'])

    response = competitionEntryTable.query(
        IndexName="matchStatusIndex",
        KeyConditionExpression=Key('matchStatus').eq('NOTMATCHED'),
        FilterExpression="""userPoolUserId <> :userPoolUserId
                            AND competitionTypeId = :competitionTypeId
                            AND categoryId = :categoryId""",
        ExpressionAttributeValues={
            ':userPoolUserId': userPoolUserId,
            ':competitionTypeId': competitionTypeId,
            ':categoryId': categoryId
        }
    )
    competitionEntries = response['Items']
    if len(competitionEntries) > 0:
        return competitionEntries.pop(0)
    else:
        return None


# Create a new Competition record with the matching CompetitionEntry records.
def createCompetition(competitionEntryRecord, competitionEntryMatch):
    competitionUUID = str(uuid.uuid4())
    competitionStartDate = str(datetime.utcnow().isoformat()+'Z')
    competitionExpireDate = str((datetime.utcnow() + timedelta(days=1)).isoformat()+'Z')
    response = competitionTable.put_item(
        Item={
            'id': competitionUUID,
            'categoryId': int(competitionEntryRecord['categoryId']),
            'competitionTypeId': int(competitionEntryRecord['competitionTypeId']),
            'expireDate': competitionExpireDate,
            'isFeatured': int(competitionEntryRecord['isFeatured']),
            'startDate': competitionStartDate,
            'status': 'ACTIVE',
            'user1CompetitionEntryId': competitionEntryRecord['id'],
            'user1ImageId': competitionEntryRecord['imageId'],
            'user1ImageSmallId': competitionEntryRecord['imageSmallId'],
            'user1RankId': int(competitionEntryRecord['userRankId']),
            'user1Username': competitionEntryRecord['username'],
            'user1VideoId': competitionEntryRecord['videoId'],
            'user1VideoPreviewImageId': competitionEntryRecord['videoPreviewImageId'],
            'user1VideoPreviewImageSmallId': competitionEntryRecord['videoPreviewImageSmallId'],
            'user1userPoolUserId': competitionEntryRecord['userPoolUserId'],
            'user2CompetitionEntryId': competitionEntryMatch['id'],
            'user2ImageId': competitionEntryMatch['imageId'],
            'user2ImageSmallId': competitionEntryMatch['imageSmallId'],
            'user2RankId': competitionEntryMatch['userRankId'],
            'user2Username': competitionEntryMatch['username'],
            'user2VideoId': competitionEntryMatch['videoId'],
            'user2VideoPreviewImageId': competitionEntryMatch['videoPreviewImageId'],
            'user2VideoPreviewImageSmallId': competitionEntryMatch['videoPreviewImageSmallId'],
            'user2userPoolUserId': competitionEntryMatch['userPoolUserId']
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('Competition record created successfully')
        return True
    else:
        print('Failed to create Competition record: {}'.format(response))
        return False

# Update the matchStatus and matchDate of the CompetitionEntry record for the given id.
def updateCompetitionEntryMatchStatus(competitionEntryRecordId):
    matchDate = str(datetime.utcnow().isoformat()+'Z')
    response = competitionEntryTable.update_item(
        Key={
            'id': competitionEntryRecordId
        },
        UpdateExpression="set matchDate = :matchDate, matchStatus = :matchStatus",
        ExpressionAttributeValues={
            ':matchDate': matchDate,
            ':matchStatus': 'MATCHED'
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('CompetitionEntry record updated successfully')
        return True
    else:
        print('Failed to update CompetitionEntry record: {}'.format(response))
        return False
