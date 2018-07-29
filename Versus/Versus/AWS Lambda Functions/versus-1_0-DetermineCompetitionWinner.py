# versus-1_0-DetermineCompetitionWinner
import boto3
import decimal
from datetime import datetime
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
competitionTable = dynamodb.Table('versus-mobilehub-387870640-AWS_Competition')
competitionVoteTable = dynamodb.Table('versus-mobilehub-387870640-AWS_CompetitionVote')
userTable = dynamodb.Table('versus-mobilehub-387870640-AWS_User')
weeklyLeaderTable = dynamodb.Table('versus-mobilehub-387870640-AWS_WeeklyLeader')
monthlyLeaderTable = dynamodb.Table('versus-mobilehub-387870640-AWS_MonthlyLeader')

def lambda_handler(event, context):

    expiredActiveCompetitions = getExpiredActiveCompetitions()

    # FOR TESTING
    print(expiredActiveCompetitions)

    # If there are expired active Competitions, process each Competition
    if expiredActiveCompetitions is not None:

        for competition in expiredActiveCompetitions:
            user1CompetitionEntryId = competition['user1CompetitionEntryId']
            user2CompetitionEntryId = competition['user2CompetitionEntryId']

            # Get the vote count for each of the CompetitionEntry records
            user1CompetitionEntryVoteCount = getVoteCountFor(user1CompetitionEntryId)
            user2CompetitionEntryVoteCount = getVoteCountFor(user2CompetitionEntryId)

            # Assign the winning user based on votes
            winningUserPoolUserId = None
            winningUserUsername = None
            losingUserPoolUserId = None
            losingUserUsername = None
            totalWinningVotes = None

            if user1CompetitionEntryVoteCount > user2CompetitionEntryVoteCount:
                winningUserPoolUserId = competition['user1userPoolUserId']
                losingUserPoolUserId = competition['user2userPoolUserId']
                winningUserUsername = competition['user1Username']
                losingUserUsername = competition['user2Username']
                totalWinningVotes = user1CompetitionEntryVoteCount
            elif user1CompetitionEntryVoteCount < user2CompetitionEntryVoteCount:
                winningUserPoolUserId = competition['user2userPoolUserId']
                losingUserPoolUserId = competition['user1userPoolUserId']
                winningUserUsername = competition['user2Username']
                losingUserUsername = competition['user1Username']
                totalWinningVotes = user2CompetitionEntryVoteCount

            competitionId = competition['id']

            # If there is a tie, extend the Competition by 1 hourd
            if winningUserPoolUserId is None:
                print('Competition {} is a tie.'.format(competitionId))
                continue
            else:
                updatedCompetitionSuccessfully = updateCompetitionRecordToComplete(competitionId, user1CompetitionEntryVoteCount, user2CompetitionEntryVoteCount, winningUserPoolUserId)
                if updatedCompetitionSuccessfully == True:

                    # Update user record
                    updatedUserWinsSuccessfully = updateWinningUserWinCount(winningUserPoolUserId)
                    if updatedUserWinsSuccessfully == True:
                        
                        # Update WeeklyLeader record
                        year = datetime.utcnow().isocalendar()[0] % 100
                        weekOfYear = datetime.utcnow().isocalendar()[1]
                        weekYear = int('{}{}'.format(weekOfYear, year))
                        updateWeeklyLeaderForWinner(winningUserPoolUserId, winningUserUsername, totalWinningVotes, weekYear)
                        
                        # Update MonthlyLeader record
                        year = datetime.utcnow().isocalendar()[0] % 100
                        monthOfYear = datetime.utcnow().month
                        yearMonth = int('{}{:02d}'.format(year, monthOfYear))
                        updateMonthlyLeaderForWinner(winningUserPoolUserId, winningUserUsername, totalWinningVotes, yearMonth)
                        
                    else:
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
        IndexName="competitionEntryIdIndex",
        KeyConditionExpression=Key('competitionEntryId').eq(competitionEntryId),
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




# Update AWS_WeeklyLeader table for winning user. Increment wins and update total vote count.
# If a record doesn't exist, insert new with 1 win and the total votes for the winning user as the total vote count.
def updateWeeklyLeaderForWinner(winningUserPoolUserId, winningUserUsername, totalWinningVotes, weekYear):

    totalWins = 1
    totalVotes = totalWinningVotes

    userWeeklyLeaderRecord = getWeeklyLeaderRecordForUser(winningUserPoolUserId, weekYear)
    if userWeeklyLeaderRecord is not None:
        totalWins = totalWins + int(userWeeklyLeaderRecord['totalWinsDuringWeek'])
        totalVotes = totalVotes + int(userWeeklyLeaderRecord['totalVotesDuringWeek'])

        updateWeeklyLeaderRecordForUser(winningUserPoolUserId, totalVotes, totalWins, weekYear)
    else:
        createWeeklyLeaderRecordForUser(winningUserPoolUserId, winningUserUsername, totalVotes, totalWins, weekYear)

    return


# Get the AWS_WeeklyLeader record for the user, if one exists.
def getWeeklyLeaderRecordForUser(winningUserPoolUserId, weekYear):
    response = weeklyLeaderTable.get_item(
       Key={
            'userPoolUserId': winningUserPoolUserId,
            'weekYear': weekYear
       }
    )
    userWeeklyLeaderRecord = None
    try:
        userWeeklyLeaderRecord = response['Item']
    except Exception as e:
        print('No WeeklyLeaderRecord found for user: {}'.format(winningUserPoolUserId))
        pass
    return userWeeklyLeaderRecord


# Update AWS_WeeklyLeader record for winning user.
def updateWeeklyLeaderRecordForUser(winningUserPoolUserId, totalVotes, totalWins, weekYear):
    updateDate = str(datetime.utcnow().isoformat()+'Z')
    response = weeklyLeaderTable.update_item(
        Key={
            'userPoolUserId': winningUserPoolUserId,
            'weekYear': weekYear
        },
        UpdateExpression="set totalVotesDuringWeek = :totalVotes, totalWinsDuringWeek = :totalWins, updateDate = :updateDate",
        ExpressionAttributeValues={
            ':totalVotes': decimal.Decimal(totalVotes),
            ':totalWins': decimal.Decimal(totalWins),
            ':updateDate': updateDate
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        return
    else:
        print('Failed to update users weekly leader record: {}'.format(response))
        return


# Create AWS_WeeklyLeader record for winning user.
def createWeeklyLeaderRecordForUser(winningUserPoolUserId, winningUserUsername, totalVotes, totalWins, weekYear):
    createDate = str(datetime.utcnow().isoformat()+'Z')
    response = weeklyLeaderTable.put_item(
        Item={
            'userPoolUserId': winningUserPoolUserId,
            'createDate': createDate,
            'username': winningUserUsername,
            'totalVotesDuringWeek': decimal.Decimal(totalVotes),
            'weekYear': decimal.Decimal(weekYear),
            'totalWinsDuringWeek': decimal.Decimal(totalWins)
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        return
    else:
        print('Failed to create WeeklyLeader record: {}'.format(response))
        return


# Get top 50 AWS_WeeklyLeader records to see if user exists in collection or if the user has more wins/ votes
# than the 50th ranked user.
def getTopWeeklyLeaderRecords():
    weekYear = None
    
    response = weeklyLeaderTable.query(
        IndexName="weekYearIndex",
        KeyConditionExpression=Key('weekYear').eq(weekYear),
        Limit=50,
        ScanIndexForward=False
    )




# Update AWS_MonthlyLeader table for winning user. Increment wins and update total vote count.
# If a record doesn't exist, insert new with 1 win and the total votes for the winning user as the total vote count.
def updateMonthlyLeaderForWinner(winningUserPoolUserId, winningUserUsername, totalWinningVotes, yearMonth):
    
    totalWins = 1
    totalVotes = totalWinningVotes
    
    userMonthlyLeaderRecord = getMonthlyLeaderRecordForUser(winningUserPoolUserId, yearMonth)
    if userMonthlyLeaderRecord is not None:
        totalWins = totalWins + int(userMonthlyLeaderRecord['totalWinsDuringMonth'])
        totalVotes = totalVotes + int(userMonthlyLeaderRecord['totalVotesDuringMonth'])
        
        updateMonthlyLeaderRecordForUser(winningUserPoolUserId, totalVotes, totalWins, yearMonth)
    else:
        createMonthlyLeaderRecordForUser(winningUserPoolUserId, winningUserUsername, totalVotes, totalWins, yearMonth)

    return


# Get the AWS_MonthlyLeader record for the user, if one exists.
def getMonthlyLeaderRecordForUser(winningUserPoolUserId, yearMonth):
    response = monthlyLeaderTable.get_item(
        Key={
            'userPoolUserId': winningUserPoolUserId,
            'yearMonth': yearMonth
        }
    )
    userMonthlyLeaderRecord = None
    try:
        userMonthlyLeaderRecord = response['Item']
    except Exception as e:
        print('No MonthlyLeaderRecord found for user: {}'.format(winningUserPoolUserId))
        pass
    return userMonthlyLeaderRecord


# Update AWS_MonthlyLeader record for winning user.
def updateMonthlyLeaderRecordForUser(winningUserPoolUserId, totalVotes, totalWins, yearMonth):
    updateDate = str(datetime.utcnow().isoformat()+'Z')
    response = monthlyLeaderTable.update_item(
        Key={
            'userPoolUserId': winningUserPoolUserId,
            'yearMonth': yearMonth
        },
        UpdateExpression="set totalVotesDuringMonth = :totalVotes, totalWinsDuringMonth = :totalWins, updateDate = :updateDate",
        ExpressionAttributeValues={
            ':totalVotes': decimal.Decimal(totalVotes),
            ':totalWins': decimal.Decimal(totalWins),
            ':updateDate': updateDate
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        return
    else:
        print('Failed to update users Monthly leader record: {}'.format(response))
        return


# Create AWS_MonthlyLeader record for winning user.
def createMonthlyLeaderRecordForUser(winningUserPoolUserId, winningUserUsername, totalVotes, totalWins, yearMonth):
    createDate = str(datetime.utcnow().isoformat()+'Z')
    response = monthlyLeaderTable.put_item(
        Item={
            'userPoolUserId': winningUserPoolUserId,
            'createDate': createDate,
            'username': winningUserUsername,
            'totalVotesDuringMonth': decimal.Decimal(totalVotes),
            'yearMonth': decimal.Decimal(yearMonth),
            'totalWinsDuringMonth': decimal.Decimal(totalWins)
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        return
    else:
        print('Failed to create monthlyLeader record: {}'.format(response))
        return
