resource "aws_cognito_user_pool" "user_pool" {
  name = var.user_pool_name

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 6
    require_lowercase = false
    require_numbers   = false
    require_symbols   = false
    require_uppercase = false
  }

  mfa_configuration = "OFF"

  admin_create_user_config {
    allow_admin_create_user_only = true

    invite_message_template {
      email_message = "Hello {username} from Recipe Sharing Serverless Application.\nYour temporary password is {####}"
      email_subject = "Your temporary password"
      sms_message   = "Hello {username}, your temporary password is {####}"
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = var.user_pool_client_name
  user_pool_id = aws_cognito_user_pool.user_pool.id

  explicit_auth_flows = ["ADMIN_NO_SRP_AUTH"]
}

resource "aws_cognito_user" "user" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  username     = var.username # e.g. "monvillarin"

  attributes = {
    email = var.user_email # e.g. "you@example.com"
  }

  desired_delivery_mediums = ["EMAIL"]
}

