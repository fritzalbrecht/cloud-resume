Cloud Resume Project
This repository contains the infrastructure as code (IaC) and related resources for hosting my cloud-based resume. The project showcases two deployment methods: one using Terraform and the other using AWS Cloud Development Kit (CDK). Both implementations ensure end-to-end encryption and utilize Cloudflare for DNS management. Additionally, an AWS Lambda@Edge function is employed to redirect visitors to the appropriate subdomain based on custom logic.

Features
Hosted Resume:

Two versions of the resume are hosted in AWS S3 buckets:
Terraform Version: Accessible at tf.fritzalbrecht.com
CDK Version: Accessible at cdk.fritzalbrecht.com
Cloudflare DNS:

Domain name management is handled via Cloudflare, with configurations automated using Terraform.
End-to-End Encryption:

SSL/TLS encryption is enabled for secure communication across all hosted resources and every AWS resource has encryption enabled as well.
Edge Lambda Redirection:

An AWS Lambda@Edge function routes visitors based on custom JavaScript logic:
Visits to fritzalbrecht.com are redirected to either tf.fritzalbrecht.com or cdk.fritzalbrecht.com.
Redirection is determined by a JavaScript function located in the cdk/lambda/edgeLambda/index.js file.
