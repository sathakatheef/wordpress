#######SNS Topics#######
resource "aws_sns_topic" "this" {
  name = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)}-sns : prod--${element(var.product,count.index)}-${element(var.purpose,count.index)}-sns"
}
