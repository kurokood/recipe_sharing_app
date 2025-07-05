variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "alb_certificate_arn" {
  description = "The ARN of the SSL certificate for the Application Load Balancer"
  type        = string
  default     = "arn:aws:acm:us-east-1:026045577315:certificate/6f9106a0-d143-4bdb-8d9c-60ec70b4e3ee"
}

variable "git-repo-url" {
  description = "URL of the Git repository to clone"
  type        = string
  default     = "https://github.com/kurokood/recipe_sharing_app.git"
}
