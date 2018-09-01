# MatchCompetitionEntries
import boto3
import uuid
from datetime import datetime
from datetime import timedelta
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
competitionEntryTable = dynamodb.Table('AWS_CompetitionEntry')
competitionTable = dynamodb.Table('AWS_Competition')

def lambda_handler(event, context):

# - Get batch of unmatched entries
# - Try to match current entry from within batch, if unable to, query compTypeCatIdRankIdMatched
# - When matched, add to collection of matched entries so the same one doesn't get matched again

    unmatchedCompetitionEntryRecords = getUnmatchedCompetitionEntryRecords()
    matchedEntryIds = []

    if unmatchedCompetitionEntryRecords is not None:

        for competitionEntryRecord in unmatchedCompetitionEntryRecords:
            match = None
            
            # Try to match with entries from current batch. Could be unsuccessful
            match = tryGetMatchFromCurrentBatch(competitionEntryRecord, unmatchedCompetitionEntryRecords, matchedEntryIds)
            
            # No match from current batch.
            if match is None:
                # Query for a matching CompetitionEntry
                match = getCompetitionEntryMatch(competitionEntryRecord)
        
            # Match was found with query
            if match is not None:

                # Create Competition record
                statusCode = createCompetition(competitionEntryRecord, match)
                
                # Competition record created successfully
                if statusCode == 200:
                    
                    # Add CompetitionEntryIds to matchedEntryIds
                    currentRecordEntryId = competitionEntryRecord['competitionEntryId']
                    matchedRecordEntryId = match['competitionEntryId']
                    matchedEntryIds.extend([currentRecordEntryId, matchedRecordEntryId])

                    # Update CompetitionEntry record statuses
                    statusCode1 = updateCompetitionEntryMatchStatus(competitionEntryRecord)
                    statusCode2 = updateCompetitionEntryMatchStatus(match)

                    if statusCode1 == 200 and statusCode2 == 200:
                        print('Successfully created competition and updated competition entries')
                    else:
                        print('Failed to update competition entries')
                else:
                    # Unable to create Competition record
                    continue
            else:
                # No match
                continue
        return 'Finished processing CompetitionEntry records'

    else:
        return 'No UNMATCHED CompetitionEntry records to process'


# Query the database for CompetitionEntry records that aren't matched.
def getUnmatchedCompetitionEntryRecords():
    response = competitionEntryTable.query(
        IndexName="awaitingMatch-index",
        KeyConditionExpression=Key('awaitingMatch').eq(1)
    )
    unmatchedCompetitionEntryRecords = response['Items']
    if len(unmatchedCompetitionEntryRecords) > 0:
        return unmatchedCompetitionEntryRecords
    else:
        return None


# Loop through existing batch of unmatched competition entries to try and find a match
def tryGetMatchFromCurrentBatch(currentRecord, unmatchedEntries, matchedEntryIds):
    currentUserId = currentRecord['userId']
    currentType = currentRecord['compTypeIdCatTypeIdRankIdMatched']

    for unmatchedEntry in unmatchedEntries:
        
        unmatchedUserId = unmatchedEntry['userId']
        unmatchedType = unmatchedEntry['compTypeIdCatTypeIdRankIdMatched']
        unmatchedEntryId = unmatchedEntry['competitionEntryId']
        
        if unmatchedUserId != currentUserId and unmatchedType == currentType and unmatchedEntryId not in matchedEntryIds:
            return unmatchedEntry
        else:
            continue

    return None


# Query for CompetitionEntry records that are not matched, doesn't belong to the same user,
# is of the same competition type, same category, and same user rank.
def getCompetitionEntryMatch(competitionEntryRecord):
    userId = competitionEntryRecord['userId']
    compTypeIdCatTypeIdRankIdMatched = competitionEntryRecord['compTypeIdCatTypeIdRankIdMatched']

    response = competitionEntryTable.query(
        IndexName="compTypeIdCatTypeIdRankIdMatched-index",
        KeyConditionExpression=Key('compTypeIdCatTypeIdRankIdMatched').eq(compTypeIdCatTypeIdRankIdMatched),
        FilterExpression="userId <> :userId",
        ExpressionAttributeValues={
            ':userId': userId
        }
    )
    competitionEntries = response['Items']
    if len(competitionEntries) > 0:
        return competitionEntries.pop(0)
    else:
        return None


# Create a new Competition record with the matching CompetitionEntry records.
def createCompetition(firstEntry, secondEntry):
    
    competitionId = str(uuid.uuid4())
    startDate = str(datetime.utcnow().isoformat()+'Z')
    expireDate = str((datetime.utcnow() + timedelta(days=1)).isoformat()+'Z')
    
    firstEntryIsFeatured = int(firstEntry['isFeatured'])
    secondEntryIsFeatured = int(secondEntry['isFeatured'])
    isFeatured = max(firstEntryIsFeatured, secondEntryIsFeatured)
    categoryTypeId = int(firstEntry['categoryTypeId'])
    isFeaturedCategoryTypeId = '{}|{}'.format(isFeatured, categoryTypeId)
    
    response = competitionTable.put_item(
        Item={
            'categoryTypeId': categoryTypeId,
            'competitionId': competitionId,
            'competitionIsActive': 1,
            'competitionTypeId': int(firstEntry['competitionTypeId']),
            'expireDate': expireDate,
            'firstEntryCommentCount': 0,
            'firstEntryCaption': firstEntry['caption'],
            'firstEntryCompetitionEntryId': firstEntry['competitionEntryId'],
            'firstEntryMediaId': firstEntry['mediaId'],
            'firstEntryUsername': firstEntry['username'],
            'firstEntryUserRankId': int(firstEntry['rankId']),
            'firstEntryUserId': firstEntry['userId'],
            'firstEntryVoteCount': 0,
            'isFeatured': isFeatured,
            'isFeaturedCategoryTypeId': isFeaturedCategoryTypeId,
            'secondEntryCommentCount': 0,
            'secondEntryCaption': secondEntry['caption'],
            'secondEntryCompetitionEntryId': secondEntry['competitionEntryId'],
            'secondEntryMediaId': secondEntry['mediaId'],
            'secondEntryUsername': secondEntry['username'],
            'secondEntryUserRankId': int(secondEntry['rankId']),
            'secondEntryUserId': secondEntry['userId'],
            'secondEntryVoteCount': 0,
            'startDate': startDate
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


# Update the matchStatus and matchDate of the CompetitionEntry record for the given id.
def updateCompetitionEntryMatchStatus(competitionEntry):
    
    competitionTypeId = int(competitionEntry['competitionTypeId'])
    categoryTypeId = int(competitionEntry['categoryTypeId'])
    rankId = int(competitionEntry['rankId'])
    compTypeIdCatTypeIdRankIdMatched = '{}|{}|{}|{}'.format(competitionTypeId, categoryTypeId, rankId, 1)
    
    response = competitionEntryTable.update_item(
        Key={
            'userId': competitionEntry['userId'],
            'createDate': competitionEntry['createDate']
        },
        UpdateExpression="SET compTypeIdCatTypeIdRankIdMatched = :val REMOVE awaitingMatch",
        ExpressionAttributeValues={
            ':val': compTypeIdCatTypeIdRankIdMatched
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']
