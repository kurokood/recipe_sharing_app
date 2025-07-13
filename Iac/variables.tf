variable "user_pool_client_name" {
  type        = string
  description = "The name for the Cognito User Pool Client"
  default     = "Pedro"
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
}

variable "user_email" {
  type        = string
  description = "The email for the initial user"
}

variable "zone_name" {
  type        = string
  description = "The name of the Route53 hosted zone"
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate for monvillarin.com"
}
