import json
import boto3

dynamodb = boto3.resource('dynamodb')

table = dynamodb.Table('cloud-resume-website-visitor-count')

def lambda_handler(event, context):
    response = table.get_item(Key={
       'ID':'Visitors-cdk-website'
    })
    
    if "Item" in response: 
        return {
            'statusCode': 200,
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps(str(response['Item']['Count']))
        }
    else:
        return {
            'statusCode': 404,
            'body': json.dumps({'message': 'Visitor not found'})
        }