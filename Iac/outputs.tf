output "http_api_endpoint" {
  description = "The endpoint of the HTTP API"
  value       = "https://${aws_apigatewayv2_api.http_api.id}.execute-api.${data.aws_region.current.id}.amazonaws.com/dev"
}

output "user_pool_id" {
  description = "The Id of the Cognito User Pool"
  value       = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  description = "The Id of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.user_pool_client.id
}

output "cognito_region" {
  description = "The AWS Region where Cognito User Pool is deployed"
  value       = data.aws_region.current.id
}

output "cloudfront_distribution_url" {
  description = "URL of the CloudFront distribution to Access your frontend"
  value       = aws_cloudfront_distribution.distribution.domain_name
}
