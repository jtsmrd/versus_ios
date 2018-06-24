# versus-1_0-DetermineCompetitionWinner
import boto3
import decimal
from datetime import datetime
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
competitionTable = dynamodb.Table('versus-mobilehub-387870640-AWS_Competition')
competitionVoteTable = dynamodb.Table('versus-mobilehub-387870640-AWS_CompetitionVote')
userTable = dynamodb.Table('versus-mobilehub-387870640-AWS_User')

def lambda_handler(event, context):

    expiredActiveCompetitions = getExpiredActiveCompetitions()

    # FOR TESTING
    print(expiredActiveCompetitions)

    # If there are expired active Competitions, process each Competition
    if expiredActiveCompetitions is not None:

        # 1. Determine winner. If tie, extend Competition 1 hour
        # 2. Update Competition record:
        #       status = 'complete'
        #       user1CompetitionEntryFinalVoteCount = <user1 vote count>
        #       user2CompetitionEntryFinalVoteCount = <user2 vote count>
        #       winningCompetitionEntryId = <winning competition entry id>
        # 3. Update the win count for the winning user
        # 4. Attempt to publish notifications for each user

        for competition in expiredActiveCompetitions:
            user1CompetitionEntryId = competition['user1CompetitionEntryId']
            user2CompetitionEntryId = competition['user2CompetitionEntryId']

            # Get the vote count for each of the CompetitionEntry records
            user1CompetitionEntryVoteCount = getVoteCountFor(user1CompetitionEntryId)
            user2CompetitionEntryVoteCount = getVoteCountFor(user2CompetitionEntryId)
            print('user1CompetitionEntryVoteCount: {}'.format(user1CompetitionEntryVoteCount))
            print('user2CompetitionEntryVoteCount: {}'.format(user2CompetitionEntryVoteCount))

            # Assign the winning user based on votes
            winningUserPoolUserId = None
            winningUserUsername = None
            losingUserPoolUserId = None
            losingUserUsername = None

            if user1CompetitionEntryVoteCount > user2CompetitionEntryVoteCount:
                winningUserPoolUserId = competition['user1userPoolUserId']
                losingUserPoolUserId = competition['user2userPoolUserId']
                winningUserUsername = competition['user1Username']
                losingUserUsername = competition['user2Username']
            elif user1CompetitionEntryVoteCount < user2CompetitionEntryVoteCount:
                winningUserPoolUserId = competition['user2userPoolUserId']
                losingUserPoolUserId = competition['user1userPoolUserId']
                winningUserUsername = competition['user2Username']
                losingUserUsername = competition['user1Username']

            competitionId = competition['id']

            # If there is a tie, extend the Competition by 1 hour
            if winningUserPoolUserId is None:
                print('Competition {} is a tie.'.format(competitionId))
                continue
            else:
                updatedCompetitionSuccessfully = updateCompetitionRecordToComplete(competitionId, user1CompetitionEntryVoteCount, user2CompetitionEntryVoteCount, winningUserPoolUserId)
                if updatedCompetitionSuccessfully == True:

                    # Update user record
                    updatedUserWinsSuccessfully = updateWinningUserWinCount(winningUserPoolUserId)
                    if updatedUserWinsSuccessfully == False:
                        print('Failed to update User wins {}.'.format(winningUserPoolUserId))
                    continue

                else:
                    print('Failed to update Competition {}.'.format(competitionId))
                    continue

    else:
        return 'No expired active Competition records to process'


# Query the database for Competition records that have expired and are active
def getExpiredActiveCompetitions():
    currentDateTime = str(datetime.utcnow().isoformat()+'Z')
    response = competitionTable.query(
        IndexName="statusIndex",
        KeyConditionExpression=Key('status').eq('ACTIVE'),
        FilterExpression=Key('expireDate').lt(currentDateTime)
    )
    expiredActiveCompetitions = response['Items']
    if len(expiredActiveCompetitions) > 0:
        return expiredActiveCompetitions
    else:
        return None


# Query the database for the count of votes for the given competitionEntryId
def getVoteCountFor(competitionEntryId):
    response = competitionVoteTable.query(
        IndexName="votedForCompetitionEntryIdIndex",
        KeyConditionExpression=Key('votedForCompetitionEntryId').eq(competitionEntryId),
        Select="COUNT"
    )
    return response['Count']


# Update Competition status, final vote count, and winning competition entry
def updateCompetitionRecordToComplete(competitionId, user1CompetitionEntryFinalVoteCount, user2CompetitionEntryFinalVoteCount, winningUserPoolUserId):
    response = competitionTable.update_item(
        Key={
            'id': competitionId
        },
        UpdateExpression="""set
            #status = :status,
            user1CompetitionEntryFinalVoteCount = :user1CompetitionEntryFinalVoteCount,
            user2CompetitionEntryFinalVoteCount = :user2CompetitionEntryFinalVoteCount,
            winningUserPoolUserId = :winningUserPoolUserId""",
        ExpressionAttributeNames={
            '#status': 'status'
        },
        ExpressionAttributeValues={
            ':status': 'COMPLETE',
            ':user1CompetitionEntryFinalVoteCount': user1CompetitionEntryFinalVoteCount,
            ':user2CompetitionEntryFinalVoteCount': user2CompetitionEntryFinalVoteCount,
            ':winningUserPoolUserId': winningUserPoolUserId
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('Updated Competition record successfully')
        return True
    else:
        print('Failed to update Competition record: {}'.format(response))
        return False


# Increment the winning users' wins
def updateWinningUserWinCount(winningUserPoolUserId):
    response = userTable.update_item(
        Key={
            'userPoolUserId': winningUserPoolUserId
        },
        UpdateExpression="set wins = :val",
        ExpressionAttributeValues={
            ':val': decimal.Decimal(1)
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        print('Updated User record successfully')
        return True
    else:
        print('Failed to update User record: {}'.format(response))
        return False
