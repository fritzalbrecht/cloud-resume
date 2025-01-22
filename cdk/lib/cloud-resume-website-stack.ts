#!/usr/bin/env node
import * as s3 from 'aws-cdk-lib/aws-s3';
import * as acm from 'aws-cdk-lib/aws-certificatemanager';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as s3deploy from 'aws-cdk-lib/aws-s3-deployment';
import * as kms from 'aws-cdk-lib/aws-kms';
import * as cloudfront_origins from 'aws-cdk-lib/aws-cloudfront-origins';
import * as lambda from 'aws-cdk-lib/aws-lambda';
import * as logs from 'aws-cdk-lib/aws-logs';
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb';
import { CfnOutput, Duration, RemovalPolicy, Stack } from 'aws-cdk-lib';
import * as iam from 'aws-cdk-lib/aws-iam';
import { Construct } from 'constructs';
import path = require('path');
import * as apigateway from 'aws-cdk-lib/aws-apigateway';

export interface StaticSiteProps {
  domainName: string;
  siteSubDomain: string;
}

export class cloudResumeWebsiteCDKStack extends Construct {
  constructor(parent: Stack, name: string, props: StaticSiteProps) {
    super(parent, name);

    const siteDomain = props.siteSubDomain + '.' + props.domainName;
    const cloudfrontOAI = new cloudfront.OriginAccessIdentity(this, 'cloud-resume-website-cdk-OAI', {
      comment: `OAI for ${name}`
    });

    new CfnOutput(this, 'Site', { value: 'https://' + siteDomain });

    const cloudResumeKMSKeyRootPolicy = new iam.PolicyDocument({
      statements: [new iam.PolicyStatement({
        actions: [
          'kms:*',
        ],
        principals: [new iam.AccountRootPrincipal()],
        resources: ['*'],
      })],
    });

    const cloudResumeKMSKey = new kms.Key(this, 'cloud-resume-kms-key-cdk', {
      enableKeyRotation: true,
      description: "Cloud resume KMS key generated using CDK.",
      policy: cloudResumeKMSKeyRootPolicy
    });

    const cloudResumeWebsiteLoggingBucket = new s3.Bucket(this, 'cloud-resume-website-logging-bucket-cdk', {
      bucketName: "cloud-resume-website-bucket-logging-cdk",
      publicReadAccess: false,
      accessControl: s3.BucketAccessControl.LOG_DELIVERY_WRITE,
      encryption: s3.BucketEncryption.KMS,
      encryptionKey: cloudResumeKMSKey
    });

    cloudResumeWebsiteLoggingBucket.addToResourcePolicy(new iam.PolicyStatement({
      actions: ['s3:GetObject', 's3:PutObject'],
      resources: [cloudResumeWebsiteLoggingBucket.arnForObjects('*')],
      principals: [new iam.ServicePrincipal('cloudfront.amazonaws.com')],
    }));

    const cloudResumeWebsiteBucket = new s3.Bucket(this, 'cloud-resume-website-bucket-cdk', {
      bucketName: "cloud-resume-website-bucket-cdk",
      publicReadAccess: false,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
    });

    cloudResumeWebsiteBucket.addToResourcePolicy(new iam.PolicyStatement({
      actions: ['s3:GetObject'],
      resources: [cloudResumeWebsiteBucket.arnForObjects('*')],
      principals: [new iam.CanonicalUserPrincipal(cloudfrontOAI.cloudFrontOriginAccessIdentityS3CanonicalUserId)]
    }));
    new CfnOutput(this, 'Bucket', { value: cloudResumeWebsiteBucket.bucketName });

    const certificateArn = "arn:aws:acm:us-east-1:144131464452:certificate/558543a5-1dc1-4f0e-81bf-333ab1047960"
    const certificate = acm.Certificate.fromCertificateArn(this, 'Certificate', certificateArn);

    const distribution = new cloudfront.Distribution(this, 'cloud-resume-website-cdk-cloudfront-distribution', {
      certificate: certificate,
      defaultRootObject: "index_cdk.html",
      domainNames: ['cdk.fritzalbrecht.com'],
      minimumProtocolVersion: cloudfront.SecurityPolicyProtocol.TLS_V1_2_2021,
      enableLogging: true,
      logBucket: cloudResumeWebsiteLoggingBucket,
      logIncludesCookies: false,
      logFilePrefix: 'cloudfront/',
      geoRestriction: cloudfront.GeoRestriction.allowlist('US', 'CA', 'GB', 'DE', 'AT'),

      defaultBehavior: {
        origin: new cloudfront_origins.S3Origin(cloudResumeWebsiteBucket, {originAccessIdentity: cloudfrontOAI}),
        compress: true,
        allowedMethods: cloudfront.AllowedMethods.ALLOW_GET_HEAD_OPTIONS,
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
      }
    });

    cloudResumeKMSKey.addToResourcePolicy(new iam.PolicyStatement({
      actions: ['kms:Decrypt', 'kms:DescribeKey', 'kms:GenerateDataKey'],
      principals: [new iam.ServicePrincipal('cloudfront.amazonaws.com')],
      effect: iam.Effect.ALLOW,
      resources: ['*'],
    }));

    new CfnOutput(this, 'DistributionId', { value: distribution.distributionId });

    new s3deploy.BucketDeployment(this, 'DeployWithInvalidation', {
      sources: [s3deploy.Source.asset(path.join(__dirname, '../site-contents'))],
      destinationBucket: cloudResumeWebsiteBucket,
      distribution,
      distributionPaths: ['/*'],
    });

    const iamRoleCDK = new iam.Role(this, 'cloud-resume-website-cdk-role', {
      roleName: 'cloud-resume-website-cdk-role',
      assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com'),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaBasicExecutionRole'),
      ]
    });

    const edgeLambda = new lambda.Function(this, 'cloud-resume-website-edge-lambda', {
      code: lambda.Code.fromAsset(path.join(__dirname, '../lambda/edgeLambda')),
      handler: 'index.handler',
      runtime: lambda.Runtime.NODEJS_LATEST,
      logRetention: logs.RetentionDays.ONE_MONTH,
      loggingFormat: lambda.LoggingFormat.JSON,
      systemLogLevelV2: lambda.SystemLogLevel.INFO,
      applicationLogLevelV2: lambda.ApplicationLogLevel.INFO,
      role: iamRoleCDK
    });

    const cloudResumeWebsiteEdgeLambdaCloudfront = new cloudfront.Distribution(this, 'cloud-resume-website-edge-lambda-cloudfront', {
      defaultBehavior: {
        origin: new cloudfront_origins.HttpOrigin('fritzalbrecht.com'),
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
        edgeLambdas: [{
          functionVersion: edgeLambda.currentVersion,
          eventType: cloudfront.LambdaEdgeEventType.VIEWER_REQUEST,
        }],
      },
      domainNames: ['fritzalbrecht.com'],
      certificate: certificate,
      minimumProtocolVersion: cloudfront.SecurityPolicyProtocol.TLS_V1_2_2021,
      enableLogging: true,
      logBucket: cloudResumeWebsiteLoggingBucket,
      logIncludesCookies: false,
      logFilePrefix: 'cloudfront/edge-lambda/',
      geoRestriction: cloudfront.GeoRestriction.allowlist('US', 'CA', 'GB', 'DE', 'AT'),
    });

    /* 
    Items cannot be created with CDK which is why a cdk table is not created here but rather an item is created in terraform
    */
    // const cloudResumeWebsiteTableCDK = new dynamodb.TableV2(this, 'cloud-resume-website-visitor-count-cdk', {
    //   partitionKey: { name: 'ID', type: dynamodb.AttributeType.STRING },
    //   encryption: dynamodb.TableEncryptionV2.customerManagedKey(cloudResumeKMSKey),
    // });

    const getVisitorsCDK = new lambda.Function(this, 'cloud-resume-website-cdk-get-visitors', {
      functionName: 'cloud-resume-website-cdk-get-visitors',
      code: lambda.Code.fromAsset(path.join(__dirname, '../lambda/getVisitors')),
      handler: 'lambda_function.lambda_handler',
      runtime: lambda.Runtime.PYTHON_3_9,
      logRetention: logs.RetentionDays.ONE_MONTH,
      loggingFormat: lambda.LoggingFormat.JSON,
      systemLogLevelV2: lambda.SystemLogLevel.INFO,
      applicationLogLevelV2: lambda.ApplicationLogLevel.INFO,
      role: iamRoleCDK
    });

    const postVisitorsCDK = new lambda.Function(this, 'cloud-resume-website-cdk-post-visitors', {
      functionName: 'cloud-resume-website-cdk-post-visitors',
      code: lambda.Code.fromAsset(path.join(__dirname, '../lambda/postVisitors')),
      handler: 'lambda_function.lambda_handler',
      runtime: lambda.Runtime.PYTHON_3_9,
      logRetention: logs.RetentionDays.ONE_MONTH,
      loggingFormat: lambda.LoggingFormat.JSON,
      systemLogLevelV2: lambda.SystemLogLevel.INFO,
      applicationLogLevelV2: lambda.ApplicationLogLevel.INFO,
      role: iamRoleCDK
    });

    iamRoleCDK.addToPolicy(new iam.PolicyStatement({
      effect: iam.Effect.ALLOW,
      actions: ['dynamodb:GetItem', 'dynamodb:PutItem'],
      resources: ['arn:aws:dynamodb:us-east-1:144131464452:table/cloud-resume-website-visitor-count'],
      sid: 'AllowDynamoDBAccess',
    }));

    iamRoleCDK.addToPolicy(new iam.PolicyStatement({
      effect: iam.Effect.ALLOW,
      actions: ['kms:Decrypt'],
      resources: [cloudResumeKMSKey.keyArn, 'arn:aws:kms:us-east-1:144131464452:key/aea10066-24a4-4af3-8f8a-a020a964817a'],
      sid: 'AllowKMSDecryption',
    }));

    const cloudResumeWebsiteVisitorCountApiCDK = new apigateway.RestApi(this, 'CloudResumeApi', {
      restApiName: 'cloud-resume-website-visitor-count-api',
      description: 'API for cloud resume website visitor count defined in CDK',
      defaultCorsPreflightOptions: {
        allowOrigins: apigateway.Cors.ALL_ORIGINS,
      },
      deployOptions: {
        stageName: 'prod',
        metricsEnabled: true,
        loggingLevel: apigateway.MethodLoggingLevel.ERROR,
      },
    });

    const getVisitorsResource = cloudResumeWebsiteVisitorCountApiCDK.root.addResource('get-visitors');
    getVisitorsResource.addMethod(
      'GET',
      new apigateway.LambdaIntegration(getVisitorsCDK),
      {
        methodResponses: [
          {
            statusCode: '200',
            responseParameters: {
              'method.response.header.Access-Control-Allow-Origin': true,
              'method.response.header.Access-Control-Allow-Headers': true,
              'method.response.header.Access-Control-Allow-Methods': true,
            },
          },
        ],
      }
    );

    const postVisitorsResource = cloudResumeWebsiteVisitorCountApiCDK.root.addResource('post-visitors');
    postVisitorsResource.addMethod(
      'POST',
      new apigateway.LambdaIntegration(postVisitorsCDK),
      {
        methodResponses: [
          {
            statusCode: '200',
            responseParameters: {
              'method.response.header.Access-Control-Allow-Origin': true,
              'method.response.header.Access-Control-Allow-Headers': true,
              'method.response.header.Access-Control-Allow-Methods': true,
            },
          },
        ],
      }
    );

    const domainName = new apigateway.DomainName(this, 'ApiDomainName', {
      domainName: 'api-cdk.fritzalbrecht.com',
      endpointType: apigateway.EndpointType.REGIONAL,
    });

    new apigateway.BasePathMapping(this, 'BasePathMapping', {
      domainName: domainName,
      certificate: certificate, 
      restApi: cloudResumeWebsiteVisitorCountApiCDK,
      stage: cloudResumeWebsiteVisitorCountApiCDK.deploymentStage,
    });

    cloudResumeWebsiteVisitorCountApiCDK.addGatewayResponse('CORS4XX', {
      type: apigateway.ResponseType.DEFAULT_4XX,
      responseHeaders: {
        'Access-Control-Allow-Origin': "'*'",
      },
      templates: {
        'application/json': '{"message":$context.error.messageString}',
      },
    });

  }
}