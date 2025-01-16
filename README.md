# Cloud Resume Project
This repository contains the infrastructure as code (IaC) and resources for hosting my cloud-based resume. The project showcases two deployment methodologies using Terraform and AWS Cloud Development Kit (CDK). Both approaches are integrated with automated GitHub Actions workflows for seamless deployment and management.

## Features
### Hosted Resume
Website: [fritzalbrecht.com]

Terraform Version: Hosted at [tf.fritzalbrecht.com]

CDK Version: Hosted at [cdk.fritzalbrecht.com]

Both versions leverage AWS S3 for static website hosting with version-specific infrastructure managed by their respective IaC tools.

### Automated Deployment Workflows
Terraform: Automatically deploys updates or performs a full deployment upon tagged releases matching the pattern terraform-*. Website files are synced to the S3 bucket and infrastructure changes are applied via Terraform.

CDK: Automatically deploys updates or performs a full deployment upon tagged releases matching the pattern cdk-*. Website files are synced to the S3 bucket, and changes are deployed using CDK.

### Cloudflare DNS
Domain name management is automated with Cloudflare via Terraform configurations, ensuring seamless integration and management.

### End-to-End Encryption
All resources are secured with SSL/TLS encryption. Additionally, all AWS resources feature encryption at rest.

### Lambda@Edge Redirection
Visitors to fritzalbrecht.com are redirected to the appropriate version of the resume (Terraform or CDK) based on custom JavaScript logic implemented in an AWS Lambda@Edge function.
