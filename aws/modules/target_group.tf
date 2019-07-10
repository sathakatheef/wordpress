resource "aws_lb_target_group" "this_tg_alb" {
  count		       = "{var.alb_count}"
  vpc_id               = "${aws_vpc.this.id}"
  name                 = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)}-tg : prod-${element(var.product,count.index)}-${element(var.purpose,count.index)}-tg"
  port                 = "${var.alb_backend_port}"
  protocol             = "${upper(var.alb_backend_protocol)}"
  deregistration_delay = "300"
  target_type          = "instance"
  slow_start           = "0"

  health_check {
    interval            = "30"
    path                = "/"
    port                = "${var.alb_health_check_port}"
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    timeout             = "5"
    protocol            = "${upper(var.alb_health_check_protocol)}"
    matcher             = "200","302"
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "86400"
    enabled         = "false"
  }

  tags {
     Name              = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)}-tg : prod-${element(var.product,count.index)}-${element(var.purpose,count.index)}-tg"
     environment       = "${var.environment == "dev" ? var.environment : "prod"}"
     product           = "${var.product}"
     product_component = "${var.product_component}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "this_tg_nlb" {
  count                = "{var.nlb_count}"
  vpc_id               = "${aws_vpc.this.id}"
  name                 = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)}-tg : prod-${element(var.product,count.index)}-${element(var.purp
ose,count.index)}-tg"
  port                 = "${var.nlb_backend_port}"
  protocol             = "${upper(var.nlb_backend_protocol)}"
  deregistration_delay = "300"
  target_type          = "ip"
  slow_start           = "0"

  health_check {
    interval            = "30"
    port                = "${var.nlb_health_check_port}"
    healthy_threshold   = "5"
    unhealthy_threshold = "5"           ###For NLB, this value should be same as healthy_threshold.
    protocol            = "${upper(var.nlb_health_check_protocol)}"
  }

  tags {
     Name              = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)}-tg : prod--${element(var.product,count.index)}-${element(var.purp
ose,count.index)}-tg"
     environment       = "${var.environment == "dev" ? var.environment : "prod"}"
     product           = "${var.product}"
     product_component = "${var.product_component}"
  }

  lifecycle {
    create_before_destroy = true
  }
}
