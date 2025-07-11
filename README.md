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
| Amazon Cognito   | Enables sercure user sig-up, sign-in, and access control for the app        |
| API Gateway      | Provides a public API endpoint that forwards requests to the Lambda function |
| Lambda Function  | Processes the application's logic for handling user read/write operations  |
| DynamoDB Table   | Stores user-submitted recipes in a NoSQL database                          |

## Key Takeaways:
This project serves as a solid foundation for gaining hands-on experience with serverless computing and AWS services. Below is a detailed overview of the key takeaways:
- Used Amazon S3 and Route 53 to host and serve the static frontend with a custom domain.
- Integrated Amazon Cognito to securely manage user authentication.
- Built backend APIs with API Gateway and Lambda to handle recipe creation and retrieval logic.
- Utilized DynamoDB to store and manage user-submitted recipes in a scalable NoSQL database.

###  Author: Mon Villarin
 📌 Portfolio Site: [Mon Villarin](https://monvillarin.com)  
 📌 Blog Post: [Building a Secure Serverless Recipe App with AWS and Terraform](https://blog.monvillarin.com/building-a-secure-serverless-recipe-app-with-aws-and-terraform)
