resource "aws_apigatewayv2_api" "http_api" {
  name          = var.api_name
  protocol_type = "HTTP"
  description   = "Recipe Sharing Application - Serverless API"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_stage" "http_api_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "dev"
  auto_deploy = true

  default_route_settings {
    throttling_burst_limit = 5
    throttling_rate_limit  = 10
  }
}

resource "aws_apigatewayv2_authorizer" "jwt_authorizer" {
  api_id           = aws_apigatewayv2_api.http_api.id
  name             = "CognitoAuthorizer"
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.user_pool_client.id]
    issuer = format(
      "https://cognito-idp.%s.amazonaws.com/%s",
      data.aws_region.current.id,
      aws_cognito_user_pool.user_pool.id
    )
  }
}

data "aws_region" "current" {}

# Test Auth Route
resource "aws_apigatewayv2_integration" "http_api_test_auth_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.auth_test_lambda_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "http_auth_test_health_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /auth"
  target    = "integrations/${aws_apigatewayv2_integration.http_api_test_auth_integration.id}"
}

# Health Check Route
resource "aws_apigatewayv2_integration" "http_api_health_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.health_check_lambda_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "http_api_health_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /health"
  target    = "integrations/${aws_apigatewayv2_integration.http_api_health_integration.id}"
}

# Get Recipes Route
resource "aws_apigatewayv2_integration" "http_api_get_recipes_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.get_recipes_lambda_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "http_api_get_recipes_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /recipes"
  target    = "integrations/${aws_apigatewayv2_integration.http_api_get_recipes_integration.id}"
}

# Post Recipe Route
resource "aws_apigatewayv2_integration" "http_api_post_recipes_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.post_recipe_lambda_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "http_api_post_recipe_route" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "POST /recipes"
  target             = "integrations/${aws_apigatewayv2_integration.http_api_post_recipes_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
}

# Delete Recipe Route
resource "aws_apigatewayv2_integration" "http_api_delete_recipe_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.delete_recipe_lambda_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "http_api_delete_recipe_route" {
  api_id             = aws_apigatewayv2_api.http_api.id
  route_key          = "DELETE /recipes/{recipe_id}"
  target             = "integrations/${aws_apigatewayv2_integration.http_api_delete_recipe_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.jwt_authorizer.id
}

# Like Recipe Route
resource "aws_apigatewayv2_integration" "http_api_like_recipes_integration" {
  api_id                 = aws_apigatewayv2_api.http_api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.like_recipe_lambda_function.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "http_api_like_recipe_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "PUT /recipes/like/{recipe_id}"
  target    = "integrations/${aws_apigatewayv2_integration.http_api_like_recipes_integration.id}"
}

resource "aws_apigatewayv2_domain_name" "api_domain" {
  domain_name = "api.monvillarin.com"

  domain_name_configuration {
    certificate_arn = "arn:aws:acm:us-east-1:026045577315:certificate/6f9106a0-d143-4bdb-8d9c-60ec70b4e3ee"
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.http_api.id
  domain_name = aws_apigatewayv2_domain_name.api_domain.id
  stage       = aws_apigatewayv2_stage.http_api_stage.id
}
