## Recipe Sharing APP

## Project Description
![](https://github.com/kurokood/recipe_sharing_app/blob/master/app-frontend.png)

This portfolio site is inspired by the concepts of the Cloud Resume Challenge by Forrest Brazeal. It demonstrates a foundational understanding of serverless architecture through a practical, hands-on project. The system architecture is illustrated below.

In this project, I provisioned a personal static portfolio site hosted on Amazon S3, integrated with Amazon CloudFront for content delivery and a custom domain managed via Route 53. The site also features a visitor counter implemented using API Gateway, an AWS Lambda function, and Amazon DynamoDB for storing visit data.

NOTE: I provisioned the entire infrastructure using Infrastructure as Code (IaC) with Terraform.

You can use the information and instructions below to replicate this project and gain hands-on experience with core Terraform and AWS concepts.
Happy learning! ☁️

## Architectural Diagram

![](https://github.com/kurokood/recipe_sharing_app/blob/master/recipe-sharing-app.png)

## Architectural Components
| Components           | Description                                                                 |
|------------------|-----------------------------------------------------------------------------|
| Route 53         | Manages a custom domain for the recipe sharing application                 |
| CloudFront       | Delivers static content from S3 via a global content delivery network (CDN) |
| S3               | Hosts the static files of the recipe sharing app                           |
| API Gateway      | Provides a public API endpoint that forwards requests to the Lambda function |
| Lambda Function  | Processes the application's logic for handling user read/write operations  |
| DynamoDB Table   | Stores user-submitted recipes in a NoSQL database                          |

## Key Takeaways:
This project serves as a solid foundation for gaining hands-on experience with serverless computing and AWS services. Below is a detailed overview of the key takeaways:
- Built and deployed a serverless, cloud-native personal resume website.
- Gained hands-on experience with AWS core services like S3, CloudFront, Route 53, Lambda, API Gateway, DynamoDB, IAM, and more.
- Connected a frontend to a backend using API Gateway + Lambda + DynamoDB to track site visits in real time.
- Applied Infrastructure as Code (IaC) using Terraform to manage and provision AWS resources efficiently.
- Integrated CI/CD workflows with GitHub Actions to automate testing and deployments.
- Strengthened understanding of cloud architecture, automation, and scalability principles.

###  Author: Mon Villarin
 📌 Portfolio Site: [Mon Villarin](https://monvillarin.com)  
 📌 Blog Post: [From Resume to the Cloud: How I Built and Deployed My Cloud Resume Challenge](https://blog.monvillarin.com/from-resume-to-the-cloud-how-i-built-and-deployed-my-cloud-resume-challenge)
