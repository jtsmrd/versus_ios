# AWS_FollowedUser_Trigger
import boto3
from datetime import datetime
from boto3.dynamodb.conditions import Key, Attr
import decimal

dynamodb = boto3.resource('dynamodb')
followerTable = dynamodb.Table('AWS_Follower')
userTable = dynamodb.Table('AWS_User')

def lambda_handler(event, context):
    
    for record in event['Records']:
        if record['eventName'] == 'INSERT':
            followedUser = record['dynamodb']['NewImage']
            statusCode = createNewFollowerRecord(followedUser)
            if statusCode == 200:
                userId = followedUser['userId']['S']
                incrementUserFollowedUserCount(userId)
                
                followedUserUserId = followedUser['followedUserUserId']['S']
                incrementUserFollowerCount(followedUserUserId)
            else:
                print('Unable to create new Follower record')
                continue
                    
        elif record['eventName'] == 'REMOVE':
            unFollowedUser = record['dynamodb']['OldImage']

            userId = unFollowedUser['userId']['S']
            decrementUserFollowedUserCount(userId)

            followedUserUserId = unFollowedUser['followedUserUserId']['S']
            decrementUserFollowerCount(followedUserUserId)
        else:
            continue

    return 'Records processed'

# Create a new AWS_Follower record for the user that was followed
def createNewFollowerRecord(followedUser):
    followerUsername = followedUser['followerUsername']['S']
    followerDisplayName = followedUser['followerDisplayName']['S']
    searchUsername = followerUsername.lower()
    searchDisplayName = followerDisplayName.lower()

    response = followerTable.put_item(
        Item={
            'userId': followedUser['followedUserUserId']['S'],
            'createDate': str(datetime.utcnow().isoformat()+'Z'),
            'followerUserId': followedUser['userId']['S'],
            'username': followerUsername,
            'displayName': followerDisplayName,
            'searchUsername': searchUsername,
            'searchDisplayName': searchDisplayName
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


# Increment the followedUserCount of the user that just followed a new user
def incrementUserFollowedUserCount(userId):
    response = userTable.update_item(
        Key={
            'userId': userId
        },
        UpdateExpression="ADD followedUserCount :val",
        ExpressionAttributeValues={
            ':val': decimal.Decimal(1)
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


# Increment the followerCount of the user that was just followed
def incrementUserFollowerCount(followedUserUserId):
    response = userTable.update_item(
        Key={
            'userId': followedUserUserId
        },
        UpdateExpression="ADD followerCount :val",
        ExpressionAttributeValues={
            ':val': decimal.Decimal(1)
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


# Decrement the followedUserCount of the user that unfollowed
def decrementUserFollowedUserCount(userId):
    response = userTable.update_item(
        Key={
            'userId': userId
        },
        UpdateExpression="ADD followedUserCount :val",
        ExpressionAttributeValues={
            ':val': decimal.Decimal(-1)
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']


# Decrement the followerCount of the unfollowed user
def decrementUserFollowerCount(followedUserUserId):
    response = userTable.update_item(
        Key={
            'userId': followedUserUserId
        },
        UpdateExpression="ADD followerCount :val",
        ExpressionAttributeValues={
            ':val': decimal.Decimal(-1)
        }
    )
    return response['ResponseMetadata']['HTTPStatusCode']
