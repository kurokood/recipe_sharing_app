data "aws_route53_zone" "hosted_zone" {
  name         = "monvillarin.com"
  private_zone = false
}

resource "aws_route53_record" "recipe_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "recipe.monvillarin.com"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "api_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "api.monvillarin.com"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.api_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
