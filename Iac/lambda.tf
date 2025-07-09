resource "aws_lambda_function" "auth_test_lambda_function" {
  function_name = "testauth"
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 60

  source_code_hash = filebase64sha256("${path.module}/lambda/auth-test.zip")

  filename = "${path.module}/lambda/auth-test.zip"
}

resource "aws_lambda_function" "health_check_lambda_function" {
  function_name = "healthcheck"
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 60

  source_code_hash = filebase64sha256("${path.module}/lambda/health-check.zip")

  filename = "${path.module}/lambda/health-check.zip"
}

resource "aws_lambda_function" "get_recipes_lambda_function" {
  function_name = "get-recipe"
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 60

  source_code_hash = filebase64sha256("${path.module}/lambda/get-recipe.zip")

  filename = "${path.module}/lambda/get-recipe.zip"
}

resource "aws_lambda_function" "post_recipe_lambda_function" {
  function_name = "post-recipe"
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 60

  source_code_hash = filebase64sha256("${path.module}/lambda/post-recipe.zip")

  filename = "${path.module}/lambda/post-recipe.zip"

  layers = ["arn:aws:lambda:us-east-1:017000801446:layer:AWSLambdaPowertoolsPythonV2:68"]

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.recipes_table.name
    }
  }
}

resource "aws_lambda_function" "delete_recipe_lambda_function" {
  function_name = "delete-recipe"
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 60

  source_code_hash = filebase64sha256("${path.module}/lambda/delete-recipe.zip")

  filename = "${path.module}/lambda/delete-recipe.zip"
}

resource "aws_lambda_function" "like_recipe_lambda_function" {
  function_name = "like-recipe"
  runtime       = "python3.9"
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  timeout       = 60

  source_code_hash = filebase64sha256("${path.module}/lambda/like-recipe.zip")

  filename = "${path.module}/lambda/like-recipe.zip"
}

resource "aws_lambda_permission" "api_gateway_auth_test_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeAuthTest"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auth_test_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_health_check_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeHealthCheck"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.health_check_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_get_recipes_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeGetRecipes"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_recipes_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_post_recipe_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokePostRecipe"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_recipe_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_delete_recipe_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeDeleteRecipe"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_recipe_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "api_gateway_like_recipe_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeLikeRecipe"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.like_recipe_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
}