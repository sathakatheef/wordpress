LB Creation################
resource "aws_lb" "this_alb" {
  count                            = "${var.logging_enabled ? 0 : var.alb_count}"      ###This is set to 0 by default. Change alb_count to 1 if ALB to be computed.
  load_balancer_type               = "application"
  name                             = "${var.environment}-${var.product}-alb"
  internal                         = "false"
  security_groups                  = ["${aws_default_security_group.this.id}", "${aws_security_group.this.id}"]
  subnets                          = ["${lookup(aws_subnet.this-pub-sn.subnet_public_ids, element(var.alb_product_roles1, count.index))}","${lookup(aws_subnet.this-pub-sn.subnet_public_ids, element(var.nlb_product_roles2, count.index))}"]                        ##########Public Subnets
  idle_timeout                     = "60"
  enable_cross_zone_load_balancing = "false"
  enable_deletion_protection       = "false"
  enable_http2                     = "true"
  ip_address_type                  = "ipv4"
  tags {
     Name              = "${var.environment}-${var.product}-alb"
     environment       = "${var.environment}"
     product           = "${var.product}"
     product_component = "${var.product_component}"
   }

  timeouts {
    create = "10m"
    delete = "10m"
    update = "10m"
  }
}

########NLB Creation################
resource "aws_lb" "this_nlb" {
  count                            = "${var.logging_enabled ? 0 : var.nlb_count}"      ###This is set to 0 by default. Change nlb_count to 1 if NLB to be computed.
  load_balancer_type               = "network"                     
  name                             = "${var.environment}-${var.product}-nlb"
  internal                         = "${var.load_balancer_is_internal}"                ###This is set to true by default.
  subnets                          = ["${lookup(aws_subnet.this-pub-sn.subnet_public_ids, element(var.nlb_product_roles1, count.index))}","${lookup(aws_subnet.this-pub-sn.subnet_public_ids, element(var.nlb_product_roles2, count.index))}"]                ##########Public Subnets
  idle_timeout                     = "60" 
  enable_cross_zone_load_balancing = "true"
  enable_deletion_protection       = "false"
  enable_http2                     = "true"
  ip_address_type                  = "ipv4"
  tags {
     Name              = "${var.environment}-${var.product}-alb"
     environment       = "${var.environment}"
     product           = "${var.product}"
     product_component = "${var.product_component}"
   }

  timeouts {
    create = "10m"
    delete = "10m"
    update = "10m"
  }
}

############HTTP Listener#############
resource "aws_lb_listener" "http_this" {
  count             = "${var.logging_enabled ? 0 : var.http_listeners_count}"
  load_balancer_arn = "${aws_lb.this_alb.arn}"
  port              = "${lookup(var.http_listeners[count.index], "port", 0)}"
  protocol          = "${lookup(var.http_listeners[count.index], "protocol", 0)}"

  default_action {
    type = "redirect"
   redirect {
       port        = "${lookup(var.http_listeners[count.index], "redirect_port", "443")}"
       protocol    = "${lookup(var.http_listeners[count.index], "redirect_protocol", "HTTPS")}"
       path        = "${lookup(var.http_listeners[count.index], "redirect_path", "/#{path}")}"
       query       = "${lookup(var.http_listeners[count.index], "redirect_query", "#{query}")}"
       status_code = "${lookup(var.http_listeners[count.index], "redirect_status_code", "HTTP_302")}"
    }
  }
}

#########Forward Listener rule for HTTP Listener###############
resource "aws_lb_listener_rule" "http_forward_this" {
  count        = "${var.logging_enabled ? 0 : var.http_listeners_forward_rule_count}"
  listener_arn = "${aws_lb_listener.http_this.*.arn[lookup(var.http_listeners_forward_rule[count.index], "listener_arn_index", 0)]}"

  action {
     type             = "${lookup(var.http_listeners_forward_rule[count.index], "rule_type", 0)}"
     target_group_arn = "${aws_lb_target_group.this_tg_alb.arn}"
  }

  condition {
     field  = "${lookup(var.http_listeners_forward_rule[count.index], "condition_field", 0)}"
     values = ["${lookup(var.http_listeners_forward_rule[count.index], "condition_values", 0)}"]
  }

  depends_on = ["aws_lb_listener.http_this"]
}

#########Redirect Listener rule for HTTP Listener###############
resource "aws_lb_listener_rule" "http_redirect_this" {
  count        = "${var.logging_enabled ? 0 : var.http_listeners_redirect_rule_count}"
  listener_arn = "${aws_lb_listener.http_this.*.arn[lookup(var.http_listeners_redirect_rule[count.index], "listener_arn_index", 0)]}"

  action {
   type = "redirect"

    redirect {
       port        = "${lookup(var.http_listeners_redirect_rule[count.index], "redirect_port", "443")}"
       protocol    = "${lookup(var.http_listeners_redirect_rule[count.index], "redirect_protocol", "HTTPS")}"
       path        = "${lookup(var.http_listeners_redirect_rule[count.index], "redirect_path", "/#{path}")}"
       query       = "${lookup(var.http_listeners_redirect_rule[count.index], "redirect_query", "#{query}")}"
       status_code = "${lookup(var.http_listeners_redirect_rule[count.index], "redirect_status_code", "HTTP_302")}"
    }
 }

   condition {
     field  = "${lookup(var.http_listeners_redirect_rule[count.index], "condition_field", 0)}"
     values = ["${lookup(var.http_listeners_redirect_rule[count.index], "condition_values", 0)}"]
  }

  depends_on = ["aws_lb_listener.http_this"]
}

############HTTPS Listener#############
resource "aws_lb_listener" "https_this" {
  count             = "${var.logging_enabled ? 0 : var.https_listeners_count}"
  load_balancer_arn = "${aws_lb.this_alb.arn}"
  port              = "${lookup(var.https_listeners[count.index], "port", 0)}"
  protocol          = "${lookup(var.https_listeners[count.index], "protocol", 0)}"
  certificate_arn   = "${aws_acm_certificate.this.arn}"
  ssl_policy        = "${lookup(var.https_listeners[count.index], "ssl_policy", var.listener_ssl_policy_default)}"

  default_action {
    target_group_arn = "${aws_lb_target_group.this_tg_alb.arn}"
    type             = "${lookup(var.https_listeners[count.index], "listener_type", 0)}"
  }
}

#########Forward Listener rule for HTTPS Listener###############
resource "aws_lb_listener_rule" "https_forward_this" {
  count        = "${var.logging_enabled ? 0 : var.https_listeners_forward_rule_count}"
  listener_arn = "${aws_lb_listener.https_this.*.arn[lookup(var.https_listeners_forward_rule[count.index], "listener_arn_index", 0)]}"

  action {
     type             = "${lookup(var.https_listeners_forward_rule[count.index], "rule_type", 0)}"
     target_group_arn = "${aws_lb_target_group.this_tg_alb.arn}"
  }

  condition {
     field  = "${lookup(var.https_listeners_forward_rule[count.index], "condition_field", 0)}"
     values = ["${lookup(var.https_listeners_forward_rule[count.index], "condition_values", 0)}"]
  }

  depends_on = ["aws_lb_listener.https_this"]
}

#########Redirect Listener rule for HTTPS Listener###############
resource "aws_lb_listener_rule" "https_redirect_this" {
  count        = "${var.logging_enabled ? 0 : var.https_listeners_redirect_rule_count}"
  listener_arn = "${aws_lb_listener.https_this.*.arn[lookup(var.https_listeners_redirect_rule[count.index], "listener_arn_index", 0)]}"

  action {
   type = "redirect"

    redirect {
       port        = "${lookup(var.https_listeners_redirect_rule[count.index], "redirect_port", "443")}"
       protocol    = "${lookup(var.https_listeners_redirect_rule[count.index], "redirect_protocol", "HTTPS")}"
       path        = "${lookup(var.https_listeners_redirect_rule[count.index], "redirect_path", "/#{path}")}"
       query       = "${lookup(var.https_listeners_redirect_rule[count.index], "redirect_query", "#{query}")}"
       status_code = "${lookup(var.https_listeners_redirect_rule[count.index], "redirect_status_code", "HTTP_302")}"
    }
 }

   condition {
     field  = "${lookup(var.https_listeners_redirect_rule[count.index], "condition_field", 0)}"
     values = ["${lookup(var.https_listeners_redirect_rule[count.index], "condition_values", 0)}"]
  }
}

############TCP Listener#############
resource "aws_lb_listener" "tcp_this" {
  count             = "${var.logging_enabled ? 0 : var.tcp_listeners_count}"
  load_balancer_arn = "${aws_lb.this_nlb.arn}"
  port              = "${lookup(var.tcp_listeners[count.index], "port", 0)}"
  protocol          = "${lookup(var.tcp_listeners[count.index], "protocol", 0)}"

  default_action {
    target_group_arn = "${aws_lb_target_group.this_tg_alb.arn}"
    type             = "${lookup(var.tcp_listeners[count.index], "listener_type", 0)}"
  }
}
