########Security Group########
resource "aws_security_group" "this" {
  name        = "${var.environment}-${var.product}-${var.sg_purpose}-sg"
  description = "Standard security group that allows all internal private IPs."
  vpc_id      = "${aws_vpc.this.id}"

  tags {
    Name   = "${var.environment}-${var.product}-${var.sg_purpose}-sg"
    Env    = "${var.environment}"
  }
}

########Security_Group_Rule########
resource "aws_security_group_rule" "this_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  self              = "true"
  security_group_id = "${aws_security_group.this.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}

########Security_Group_Rule########
resource "aws_security_group_rule" "this_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  self              = "true"
  security_group_id = "${aws_security_group.this.id}"
  cidr_blocks       = ["10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"]
}
