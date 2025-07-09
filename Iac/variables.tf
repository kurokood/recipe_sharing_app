variable "user_pool_client_name" {
  type        = string
  description = "The name for the Cognito User Pool Client"
  default     = "mon villarin"
}

variable "api_name" {
  type        = string
  description = "API Name"
  default     = "recipe-app-api"
}

variable "user_pool_name" {
  type        = string
  description = "The name for the Cognito User Pool"
  default     = "cognito-userpool"
}

variable "username" {
  type        = string
  description = "The username for the initial user"
  default     = "admin"
}

variable "user_email" {
  type        = string
  description = "The email for the initial user"
  default     = "villarinmon@gmail.com"
}
