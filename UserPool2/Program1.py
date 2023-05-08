import json
import boto3

client = boto3.client('cognito-idp')

def lambda_handler(event, context):
    if (event['triggerSource'] == 'UserMigration_Authentication'):
        user = client.admin_initiate_auth(
            UserPoolId='<UserPool id of Userpool1>',
            ClientId='<ClientId of Userpool1>',
            AuthFlow='ADMIN_NO_SRP_AUTH',
            AuthParameters={
                'USERNAME': event['userName'],
                'PASSWORD': event['request']['password']
            }
        )
        if (user):
            userAttributes = client.get_user(
                AccessToken=user['AuthenticationResult']['AccessToken']
            )
            for userAttribute in userAttributes['UserAttributes']:
                if userAttribute['Name'] == 'email':
                    userEmail = userAttribute['Value']
                    # print(userEmail)
                    event['response']['userAttributes'] = {
                        "email": userEmail,
                        "email_verified": "true"
                    }
            event['response']['messageAction'] = "SUPPRESS"
            print(event)
            return event
        else:
            return 'Bad Password'
    elif (event["triggerSource"] == "UserMigration_ForgotPassword"):
        user = client.admin_get_user(
            UserPoolId='<UserPool id of Userpool1>',
            Username=event['userName']
        )
        if (user):
            for userAttribute in user['UserAttributes']:
                if userAttribute['Name'] == 'email':
                    userEmail = userAttribute['Value']
                    print(userEmail)
                    event['response']['userAttributes'] = {
                        "email": userEmail,
                        "email_verified": "true"
                    }
            event['response']['messageAction'] = "SUPPRESS"
            print(event)
            return event
        else:
            return 'Bad Password'
    else:
        return 'There was an error'
