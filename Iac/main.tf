terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ssm_parameter" "recipe_latest_ami_id" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_dynamodb_table" "recipes" {
  name         = "recipes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_iam_policy" "recipe_ec2_instance_policy" {
  name        = "ec2-instance-policy"
  description = "Policy for EC2 instance to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan",
          "dynamodb:DeleteItem"
        ]
        Resource = aws_dynamodb_table.recipes.arn
      }
    ]
  })
}

resource "aws_iam_role" "recipe_ec2_instance_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.recipe_ec2_instance_role.name
  policy_arn = aws_iam_policy.recipe_ec2_instance_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.recipe_ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.recipe_ec2_instance_role.name
}

resource "aws_vpc" "recipe_main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "Recipe 3 VPC"
  }
}

resource "aws_internet_gateway" "recipe_main" {
  vpc_id = aws_vpc.recipe_main.id

  tags = {
    Name = "Recipe 3 IGW"
  }
}

resource "aws_subnet" "recipe_private_1" {
  vpc_id            = aws_vpc.recipe_main.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "recipe_private_2" {
  vpc_id            = aws_vpc.recipe_main.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.3.0/24"

  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_route_table" "recipe_private" {
  vpc_id = aws_vpc.recipe_main.id

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "recipe_private_1" {
  subnet_id      = aws_subnet.recipe_private_1.id
  route_table_id = aws_route_table.recipe_private.id
}

resource "aws_route_table_association" "recipe_private_2" {
  subnet_id      = aws_subnet.recipe_private_2.id
  route_table_id = aws_route_table.recipe_private.id
}

resource "aws_subnet" "recipe_public_1" {
  vpc_id                  = aws_vpc.recipe_main.id
  availability_zone       = data.aws_availability_zones.available.names[0]
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "recipe_public_2" {
  vpc_id                  = aws_vpc.recipe_main.id
  availability_zone       = data.aws_availability_zones.available.names[1]
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_route_table" "recipe_public" {
  vpc_id = aws_vpc.recipe_main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.recipe_main.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "recipe_public_1" {
  subnet_id      = aws_subnet.recipe_public_1.id
  route_table_id = aws_route_table.recipe_public.id
}

resource "aws_route_table_association" "recipe_public_2" {
  subnet_id      = aws_subnet.recipe_public_2.id
  route_table_id = aws_route_table.recipe_public.id
}

resource "aws_eip" "recipe_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "recipe_main" {
  allocation_id = aws_eip.recipe_nat.id
  subnet_id     = aws_subnet.recipe_public_1.id

  tags = {
    Name = "Recipe 3 NAT Gateway"
  }
}

resource "aws_route" "recipe_private_nat" {
  route_table_id         = aws_route_table.recipe_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.recipe_main.id
}

resource "aws_security_group" "recipe_alb" {
  name        = "alb-sg"
  description = "Allow HTTPS"
  vpc_id      = aws_vpc.recipe_main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2" {
  name        = "ec2-sg"
  description = "Allow HTTP from ALB"
  vpc_id      = aws_vpc.recipe_main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.recipe_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "recipe_main" {
  ami                    = data.aws_ssm_parameter.recipe_latest_ami_id.value
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id              = aws_subnet.recipe_private_1.id
  vpc_security_group_ids = [aws_security_group.ec2.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y python3 python3-pip python3-virtualenv nginx jq
    git clone ${var.git-repo-url}
    cp -r $(echo "${var.git-repo-url}" | sed 's/.*\///' | sed 's/\.git//')/chapter3/code/backend . ; rm -rf $(echo "${var.git-repo-url}" | sed 's/.*\///' | sed 's/\.git//') ; cd backend

    sed -i "s/SELECTED_REGION/$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')/g" main.py
    
    # Create an Nginx configuration file
    cat << EOL > /etc/nginx/sites-available/fastapi
    server {
    listen 80;
    server_name ~.;
    location / {
    proxy_pass http://localhost:8000;
    }
    }
    EOL
    
    sudo ln -s /etc/nginx/sites-available/fastapi /etc/nginx/sites-enabled/
    sudo systemctl restart nginx
    virtualenv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
    python3 -m uvicorn main:app &
  EOF

  tags = {
    Name = "Recipe_API"
  }
}

resource "aws_lb" "recipe_main" {
  name               = "recipe-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.recipe_alb.id]
  subnets            = [aws_subnet.recipe_public_1.id, aws_subnet.recipe_public_2.id]
}

resource "aws_lb_target_group" "recipe_main" {
  name        = "recipe-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.recipe_main.id
  target_type = "instance"

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "recipe_https" {
  load_balancer_arn = aws_lb.recipe_main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.recipe_main.arn
  }
}

resource "aws_lb_target_group_attachment" "recipe_main" {
  target_group_arn = aws_lb_target_group.recipe_main.arn
  target_id        = aws_instance.recipe_main.id
  port             = 80
}

resource "aws_s3_bucket" "recipe_sharing_app" {
  bucket = "recipe-sharing-app121485"

  tags = {
    Name = "Frontend Bucket"
  }
}

resource "random_id" "stack" {
  byte_length = 8
}

resource "aws_s3_bucket_public_access_block" "recipe_sharing_app" {
  bucket = aws_s3_bucket.recipe_sharing_app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "recipe_sharing_app" {
  name                              = "OAC for ${aws_s3_bucket.recipe_sharing_app.id}"
  description                       = "Origin Access Control for S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_s3_bucket_policy" "recipe_sharing_app" {
  bucket = aws_s3_bucket.recipe_sharing_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.recipe_sharing_app.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.recipe_sharing_app.arn
          }
        }
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "recipe_sharing_app" {
  origin {
    domain_name              = aws_s3_bucket.recipe_sharing_app.bucket_regional_domain_name
    origin_id                = "origin-s3-${aws_s3_bucket.recipe_sharing_app.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.recipe_sharing_app.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  http_version        = "http2"
  price_class         = "PriceClass_100"
  aliases             = ["recipe.monvillarin.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-s3-${aws_s3_bucket.recipe_sharing_app.id}"

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

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:026045577315:certificate/6f9106a0-d143-4bdb-8d9c-60ec70b4e3ee"
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

output "cloudfront_distribution_url" {
  description = "URL of the CloudFront distribution to Access our frontend"
  value       = aws_cloudfront_distribution.recipe_sharing_app.domain_name
}

output "cloudfront_distribution_id" {
  description = "The CloudFront Distribution ID"
  value       = aws_cloudfront_distribution.recipe_sharing_app.id
}

output "application_load_balancer_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.recipe_main.dns_name
}

data "aws_route53_zone" "main" {
  name = "monvillarin.com"
}

resource "aws_route53_record" "recipe" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "recipe.${data.aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.recipe_sharing_app.domain_name
    zone_id                = aws_cloudfront_distribution.recipe_sharing_app.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "api.${data.aws_route53_zone.main.name}"
  type    = "A"

  alias {
    name                   = aws_lb.recipe_main.dns_name
    zone_id                = aws_lb.recipe_main.zone_id
    evaluate_target_health = true
  }
}
