## Serverless Recipe Sharing App with Secure User Authentication via Amazon Cognito

## Project Description
![](https://github.com/kurokood/recipe_sharing_app/blob/master/app-frontend.png)

Recipe Sharing App is a fully serverless, cloud-native web application built on AWS. The frontend is hosted on Amazon S3 and delivered globally through CloudFront, with a custom domain managed via Route 53. User authentication is securely handled using Amazon Cognito, allowing users to sign up, log in, and manage their sessions.

The application backend is powered by API Gateway and AWS Lambda, which manage the core logic for submitting and retrieving recipes. All recipe data is stored in Amazon DynamoDB, a scalable NoSQL database. This project demonstrates best practices in serverless architecture, authentication, and real-world use of AWS services for modern web applications.

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
 📌 LinkedIn: [Ramon Villarin](https://www.linkedin.com/in/ramon-villarin/)
 📌 Portfolio Site: [Mon Villarin](https://monvillarin.com)  
 📌 Blog Post: [Building a Secure Serverless Recipe App with AWS and Terraform](https://blog.monvillarin.com/building-a-secure-serverless-recipe-app-with-aws-and-terraform)
