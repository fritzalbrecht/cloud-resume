import json
import boto3

dynamodb = boto3.resource('dynamodb')

table = dynamodb.Table('visitors')

def lambda_handler(event, context):
    response = table.get_item(Key={
            'ID':'0'
    })
    record_count = response['Item']['visitors']
    record_count = record_count + 1
    print(record_count)
    response = table.put_item(Item={
            'ID':'0',
            'visitors': record_count
    })
    
    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        },
        'body': json.dumps(str(record_count))
    }