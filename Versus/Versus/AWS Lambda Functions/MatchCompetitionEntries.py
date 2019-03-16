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
                match = getCompetitionEntryMatch(competitionEntryRecord, matchedEntryIds)
        
            # Match was found with query
            if match is not None:

                # Add CompetitionEntryIds to matchedEntryIds
                currentRecordEntryId = competitionEntryRecord['competitionEntryId']
                matchedRecordEntryId = match['competitionEntryId']
                matchedEntryIds.extend([currentRecordEntryId, matchedRecordEntryId])
                print('Matched Entry IDs: {}'.format(matchedEntryIds))

                # Create Competition record
                statusCode = createCompetition(competitionEntryRecord, match)
                
                # Competition record created successfully
                if statusCode == 200:

                    # Update Entry record statuses
                    statusCode1 = updateCompetitionEntryMatchStatus(competitionEntryRecord)
                    statusCode2 = updateCompetitionEntryMatchStatus(match)

                    if statusCode1 == 200 and statusCode2 == 200:
                        print('Successfully created competition and updated competition entries')
                    else:
                        print('Failed to update competition entries')
                else:
                    # Unable to create Competition record. Remove competition entry ids from matchedEntryIds
                    matchedEntryIds.remove(currentRecordEntryId)
                    matchedEntryIds.remove(matchedRecordEntryId)
                    print('Failed to create Competition record')
                    
                    continue
            else:
                # No match
                print('No match for competitionEntryId: {}'.format(competitionEntryRecord['competitionEntryId']))
                continue
        return 'Finished processing CompetitionEntry records'

    else:
        return 'No UNMATCHED CompetitionEntry records to process'


# Query the database for CompetitionEntry records that aren't matched.
def getUnmatchedCompetitionEntryRecords():
    currentDateTime = str(datetime.utcnow().isoformat()+'Z')
    response = competitionEntryTable.query(
        IndexName="awaitingMatch-createDate-index",
        KeyConditionExpression=Key('awaitingMatch').eq(1) & Key('createDate').lt(currentDateTime),
        ScanIndexForward=False,
        Limit=25 #REMOVE
    )
    unmatchedCompetitionEntryRecords = response['Items']
    if len(unmatchedCompetitionEntryRecords) > 0:
        print('{} unmatched records'.format(len(unmatchedCompetitionEntryRecords)))
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
            print('Found match in current batch')
            return unmatchedEntry
        else:
            continue

    return None


# Query for CompetitionEntry records that are not matched, doesn't belong to the same user,
# is of the same competition type, same category, and same user rank.
def getCompetitionEntryMatch(competitionEntryRecord, matchedEntryIds):
    userId = competitionEntryRecord['userId']
    compTypeIdCatTypeIdRankIdMatched = competitionEntryRecord['compTypeIdCatTypeIdRankIdMatched']
    currentDateTime = str(datetime.utcnow().isoformat()+'Z')
    response = competitionEntryTable.query(
        IndexName="compTypeIdCatTypeIdRankIdMatched-createDate-index",
        KeyConditionExpression=Key('compTypeIdCatTypeIdRankIdMatched').eq(compTypeIdCatTypeIdRankIdMatched) & Key('createDate').lt(currentDateTime),
        FilterExpression="userId <> :userId",
        ExpressionAttributeValues={
            ':userId': userId
        },
        ScanIndexForward=False
    )
    
    competitionEntries = response['Items']
    if len(competitionEntries) > 0:
        print('Found potential match from query')
        for competitionEntry in competitionEntries:
            competitionEntryId = competitionEntry['competitionEntryId']
        
            if competitionEntryId not in matchedEntryIds:
                print('Found match from query')
                return competitionEntry
            else:
                continue
        
        print('Potential match already matched')
        return None
    else:
        print('No potential matches from query')
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
            'firstCompetitorCommentCount': 0,
            'firstCompetitorCaption': firstEntry['caption'],
            'firstCompetitorEntryId': firstEntry['competitionEntryId'],
            'firstCompetitorMediaId': firstEntry['mediaId'],
            'firstCompetitorUsername': firstEntry['username'],
            'firstCompetitorUserRankId': int(firstEntry['rankId']),
            'firstCompetitorUserId': firstEntry['userId'],
            'firstCompetitorVoteCount': 0,
            'isFeatured': isFeatured,
            'isFeaturedCategoryTypeId': isFeaturedCategoryTypeId,
            'secondCompetitorCommentCount': 0,
            'secondCompetitorCaption': secondEntry['caption'],
            'secondCompetitorEntryId': secondEntry['competitionEntryId'],
            'secondCompetitorMediaId': secondEntry['mediaId'],
            'secondCompetitorUsername': secondEntry['username'],
            'secondCompetitorUserRankId': int(secondEntry['rankId']),
            'secondCompetitorUserId': secondEntry['userId'],
            'secondCompetitorVoteCount': 0,
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
            'userId': competitionEntry['userId']
        },
        UpdateExpression="SET compTypeIdCatTypeIdRankIdMatched = :val REMOVE awaitingMatch",
        ExpressionAttributeValues={
            ':val': compTypeIdCatTypeIdRankIdMatched
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']
