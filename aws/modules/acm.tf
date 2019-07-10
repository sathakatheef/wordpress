########1STOP wildcard certificate Import########
resource "aws_acm_certificate" "this" {
  private_key       = "${file(var.private_key)}"
  certificate_body  = "${file(var.certificate_body)}"
  certificate_chain = "${file(var.certificate_chain)}"

  tags = {
    Name              = "${var.environment == "dev" ? var.environment : "prod"}-${var.product}-wildcard"
    environment       = "${var.environment == "dev" ? var.environment : "prod"}"
    product           = "${var.product}"
    product_component = "wildcard_certificate"
  }
}
