import json
import boto3


dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('visitors')

def lambda_handler(event, context):
    response = table.get_item(Key={
       'ID':'0'
    })
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps(str(response['Item']['visitors']))
    }