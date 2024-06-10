import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as apigateway from 'aws-cdk-lib/aws-apigateway';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import * as kms from 'aws-cdk-lib/aws-kms';
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import { Service } from 'aws-cdk-lib/aws-servicediscovery';
import { getServers } from 'dns';


export class CdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);



    const cloudResumeKey = new kms.Key(this, 'cdkCloudResumeKey', {
      enableKeyRotation: true,
    });

    const cloudResumeS3BucketCDK = new s3.Bucket(this, 'cloud-resume-bucket-cdk');
    const cloudResumeCloudFrontDist = new cloudfront.Distribution(this, 'myDist', {
      defaultBehavior: { origin: new origins.S3Origin(cloudResumeS3BucketCDK) },
    });



    const visitorTableCDK = new dynamodb.TableV2(this, 'visitorCountCDK', {
      partitionKey: { name: 'ID', type: dynamodb.AttributeType.STRING },
      encryption: dynamodb.TableEncryptionV2.customerManagedKey(cloudResumeKey)
    });
    

    const lambdaRole = new iam.Role(this, 'LambdaRole', {
      assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com'),
    });


    lambdaRole.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaBasicExecutionRole'));
    lambdaRole.addToPolicy(new iam.PolicyStatement({
      actions: ["dynamodb:GetItem","dynamodb:PutItem"],
      resources: ['arn:aws:s3:::example-bucket/*'],
    }));


    const getVisitorsCDK = new lambda.Function(this, 'getVisitorsCDK', {
      runtime: lambda.Runtime.PYTHON_3_12,
      code: lambda.Code.fromAsset('lambda'),
      handler: 'get_visitors_cdk.lambda_handler',
      role: lambdaRole
    });

    const api = new apigateway.LambdaRestApi(this, 'VisitorCountAPI-CDK', {
      handler: getVisitorsCDK,
      proxy: false,
    });

    
    const getResource = api.root.addResource('getVisitors');
    getResource.addMethod('GET');
  
  
    const KMSKeyPolicyStatementsCDK =[ new iam.PolicyDocument({
      statements: [new iam.PolicyStatement({
        actions: ['kms:*'],
        principals: [new iam.AccountRootPrincipal()],
        resources: ['*'],
      }), new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ],
        resources: ['*'],
        conditions: {
          StringEquals: {
            'aws:RequestTag/Environment': 'production',
          },
          ArnEquals: {
            'kms:EncryptionContext:aws:logs:arn': 'arn:aws:logs:us-east-1:${var.aws_account_id}:*',
            'aws:SourceArn': getVisitorsCDK.functionArn
          }
        },
        principals: [
          new iam.ServicePrincipal('logs.us-east-1.amazonaws.com'), 
          new iam.ServicePrincipal('cloudfront.amazonaws.com'),
          new iam.ServicePrincipal('delivery.logs.amazonaws.com'),
        ]
      })],
    })];
  }
}
