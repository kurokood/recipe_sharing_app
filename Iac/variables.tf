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

variable "zone_name" {
  type        = string
  description = "The name of the Route53 hosted zone"
  default     = "monvillarin.com"
}

variable "acm_certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate for monvillarin.com"
  default     = "arn:aws:acm:us-east-1:026045577315:certificate/6f9106a0-d143-4bdb-8d9c-60ec70b4e3ee"
}
