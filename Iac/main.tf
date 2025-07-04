terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-bucket-abc1"
    key            = "recipe-sharing-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "recipe_sharing_app_alb" {
  name        = "recipe_sharing_app_alb"
  description = "Allow all inbound traffic for ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "recipe_sharing_app_asg" {
  name        = "recipe_sharing_app_asg"
  description = "Allow inbound traffic from ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.recipe_sharing_app_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "recipe_sharing_app" {
  name               = "recipe-sharing-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.recipe_sharing_app_alb.id]
  subnets            = data.aws_subnets.default.ids
  ip_address_type    = "ipv4"
}

resource "aws_lb_target_group" "recipe_sharing_app" {
  name     = "recipe-sharing-app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_lb_listener" "recipe_sharing_app" {
  load_balancer_arn = aws_lb.recipe_sharing_app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.recipe_sharing_app.arn
  }
}

resource "aws_iam_role" "recipe_sharing_app_ec2_role" {
  name = "recipe_sharing_app_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_access" {
  name        = "dynamodb_access_policy"
  description = "Policy for DynamoDB access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:DeleteItem"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.recipe_sharing_table.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb_access_attachment" {
  role       = aws_iam_role.recipe_sharing_app_ec2_role.name
  policy_arn = aws_iam_policy.dynamodb_access.arn
}

resource "aws_iam_instance_profile" "recipe_sharing_app_ec2_profile" {
  name = "recipe_sharing_app_ec2_profile"
  role = aws_iam_role.recipe_sharing_app_ec2_role.name
}

resource "aws_launch_template" "recipe_sharing_app_template" {
  name_prefix   = "recipe_sharing_app_template"
  image_id      = "ami-05ffe3c48a9991133"
  instance_type = "t2.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.recipe_sharing_app_ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.recipe_sharing_app_asg.id]
  }
}

resource "aws_autoscaling_group" "recipe_sharing_app" {
  name                = "recipe_sharing_app"
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1
  vpc_zone_identifier = data.aws_subnets.default.ids

  launch_template {
    id      = aws_launch_template.recipe_sharing_app_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.recipe_sharing_app.arn]
}

resource "aws_dynamodb_table" "recipe_sharing_table" {
  name         = "recipe_sharing_table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_s3_bucket" "recipe_sharing_site" {
  bucket = "recipe-sharing-site"
}

resource "aws_s3_bucket_acl" "recipe_sharing_site_acl" {
  bucket = aws_s3_bucket.recipe_sharing_site.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "recipe_sharing_site_public_access" {
  bucket = aws_s3_bucket.recipe_sharing_site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "recipe_sharing_site_versioning" {
  bucket = aws_s3_bucket.recipe_sharing_site.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "recipe_sharing_site_encryption" {
  bucket = aws_s3_bucket.recipe_sharing_site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
      kms_master_key_id = null
    }
    bucket_key_enabled = true
  }
}



resource "aws_s3_bucket_website_configuration" "recipe_sharing_site_website" {
  bucket = aws_s3_bucket.recipe_sharing_site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_cloudfront_distribution" "recipe_sharing_app" {
  origin {
    domain_name = aws_s3_bucket.recipe_sharing_site.bucket_regional_domain_name
    origin_id   = "S3-recipe-sharing-site"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "recipe_sharing_app"
  default_root_object = "index.html"

  aliases = ["recipe.monvillarin.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-recipe-sharing-site"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:026045577315:certificate/6f9106a0-d143-4bdb-8d9c-60ec70b4e3ee"
    ssl_support_method  = "sni-only"
  }
}

data "aws_route53_zone" "monvillarin" {
  name = "monvillarin.com"
}

resource "aws_route53_record" "recipe_monvillarin_com" {
  zone_id = data.aws_route53_zone.monvillarin.zone_id
  name    = "recipe.${data.aws_route53_zone.monvillarin.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.recipe_sharing_app.domain_name
    zone_id                = aws_cloudfront_distribution.recipe_sharing_app.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "recipe_monvillarin_com" {
  zone_id = data.aws_route53_zone.monvillarin.zone_id
  name    = "api.${data.aws_route53_zone.monvillarin.name}"
  type    = "A"

  alias {
    name                   = aws_lb.recipe_sharing_app.dns_name
    zone_id                = aws_lb.recipe_sharing_app.zone_id
    evaluate_target_health = true
  }
}
