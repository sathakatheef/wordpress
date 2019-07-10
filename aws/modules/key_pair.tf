resource "aws_key_pair" "this" {
  key_name = "amazon-prod"
  public_key = "${file("var.pub_key")}"
}
