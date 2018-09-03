# versus-1_0-DetermineCompetitionWinner
import boto3
import decimal
from datetime import datetime
from boto3.dynamodb.conditions import Key, Attr

dynamodb = boto3.resource('dynamodb')
competitionTable = dynamodb.Table('AWS_Competition')
competitionVoteTable = dynamodb.Table('AWS_CompetitionVote')
userTable = dynamodb.Table('AWS_User')
weeklyLeaderTable = dynamodb.Table('AWS_WeeklyLeader')
monthlyLeaderTable = dynamodb.Table('AWS_MonthlyLeader')

def lambda_handler(event, context):

    expiredActiveCompetitions = getExpiredActiveCompetitions()

    # FOR TESTING
    print(expiredActiveCompetitions)

    # If there are expired active Competitions, process each Competition
    if expiredActiveCompetitions is not None:

        for competition in expiredActiveCompetitions:
            firstEntryCompetitionEntryId = competition['firstCompetitorEntryId']
            secondEntryCompetitionEntryId = competition['secondCompetitorEntryId']

            # Get the vote count for each of the CompetitionEntry records
            firstEntryVoteCount = int(competition['firstCompetitorVoteCount'])
            secondEntryVoteCount = int(competition['secondCompetitorVoteCount'])
            
            firstEntryUserId = competition['firstCompetitorUserId']
            firstEntryUsername = competition['firstCompetitorUsername']
            secondEntryUserId = competition['secondCompetitorUserId']
            secondEntryUsername = competition['secondCompetitorUsername']

            # Assign the winning user based on votes
            winningUserId = None
            winningUsername = None
            losingUserId = None
            losingUsername = None
            totalWinningVotes = None

            if firstEntryVoteCount > secondEntryVoteCount:
                winningUserId = firstEntryUserId
                losingUserId = secondEntryUserId
                winningUsername = firstEntryUsername
                losingUsername = secondEntryUsername
                totalWinningVotes = firstEntryVoteCount
            elif firstEntryVoteCount < secondEntryVoteCount:
                winningUserId = secondEntryUserId
                losingUserId = firstEntryUserId
                winningUsername = secondEntryUsername
                losingUsername = firstEntryUsername
                totalWinningVotes = secondEntryVoteCount

            competitionId = competition['competitionId']

            # If there is a tie, extend the Competition by 1 hourd
            if winningUserPoolUserId is None:
                print('Competition {} is a tie.'.format(competitionId))
                continue
            else:
                statusCode = updateCompetitionRecordToComplete(competitionId, winningUserId)
                if statusCode == 200:

                    # Update user record
                    statusCode = updateWinningUserWinCount(winningUserId)
                    if statusCode == 200:
                        
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
        IndexName="competitionIsActive-startDate-index",
        KeyConditionExpression=Key('competitionIsActive').eq(1) & Key('startDate').lt(currentDateTime),
        FilterExpression=Key('expireDate').lt(currentDateTime),
        ScanIndexForward=False
    )
    expiredActiveCompetitions = response['Items']
    if len(expiredActiveCompetitions) > 0:
        return expiredActiveCompetitions
    else:
        return None


# Update Competition status, final vote count, and winning competition entry
def updateCompetitionRecordToComplete(competitionId, winningUserId):
    response = competitionTable.update_item(
        Key={
            'competitionId': competitionId
        },
        UpdateExpression="set winnerUserId = :userId REMOVE competitionIsActive",
        ExpressionAttributeValues={
            ':userId': winningUserId
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


# Increment the winning users' wins
def updateWinningUserWinCount(winningUserId):
    response = userTable.update_item(
        Key={
            'userId': winningUserId
        },
        UpdateExpression="ADD totalWins :val",
        ExpressionAttributeValues={
            ':val': decimal.Decimal(1)
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


# Update AWS_WeeklyLeader table for winning user. Increment wins and update total vote count.
# If a record doesn't exist, insert new with 1 win and the total votes for the winning user as the total vote count.
def updateWeeklyLeaderForWinner(winningUserId, winningUsername, totalWinningVotes, weekYear):

    totalWins = 1
    totalVotes = totalWinningVotes

    userWeeklyLeaderRecord = getWeeklyLeaderRecordForUser(winningUserId, weekYear)
    if userWeeklyLeaderRecord is not None:
        totalWins = totalWins + int(userWeeklyLeaderRecord['wins'])
        totalVotes = totalVotes + int(userWeeklyLeaderRecord['votes'])

        updateWeeklyLeaderRecordForUser(winningUserId, totalVotes, totalWins, weekYear)
    else:
        createWeeklyLeaderRecordForUser(winningUserId, winningUsername, totalVotes, totalWins, weekYear)

    return


# Get the AWS_WeeklyLeader record for the user, if one exists.
def getWeeklyLeaderRecordForUser(winningUserId, weekYear):
    weekYearUserId = '{}{}'.format(weekYear, winningUserId)
    response = weeklyLeaderTable.get_item(
       Key={
            'weekYearUserId': weekYearUserId
       }
    )
    userWeeklyLeaderRecord = None
    try:
        userWeeklyLeaderRecord = response['Item']
    except Exception as e:
        print('No WeeklyLeaderRecord found for user: {}'.format(winningUserId))
        pass
    return userWeeklyLeaderRecord


# Update AWS_WeeklyLeader record for winning user.
def updateWeeklyLeaderRecordForUser(winningUserId, totalVotes, totalWins, weekYear):
    weekYearUserId = '{}{}'.format(weekYear, winningUserId)
    response = weeklyLeaderTable.update_item(
        Key={
            'weekYearUserId': weekYearUserId
        },
        UpdateExpression="set votes = :totalVotes, wins = :totalWins",
        ExpressionAttributeValues={
            ':totalVotes': decimal.Decimal(totalVotes),
            ':totalWins': decimal.Decimal(totalWins)
        }
    )
    if response['ResponseMetadata']['HTTPStatusCode'] == 200:
        return
    else:
        print('Failed to update users weekly leader record: {}'.format(response))
        return


# Create AWS_WeeklyLeader record for winning user.
def createWeeklyLeaderRecordForUser(winningUserId, winningUsername, totalVotes, totalWins, weekYear):
    weekYearUserId = '{}{}'.format(weekYear, winningUserId)
    response = weeklyLeaderTable.put_item(
        Item={
            'userId': winningUserId,
            'username': winningUsername,
            'votes': decimal.Decimal(totalVotes),
            'weekYear': decimal.Decimal(weekYear),
            'weekYearUserId': weekYearUserId,
            'wins': decimal.Decimal(totalWins)
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
