###Check for User Data
data "template_file" "user_data" {
###If the user data file is empty, user_data wont be computed, otherwise user data will be computed. An empty file must be specified for this logic to work (even if user data is not to be computed)
    template = "${var.tpl_file == "" ? var.tpl_file : file("${var.tpl_file_path}")}"
    vars = {
             db_hostname = "${aws_rds_cluster.aurora.endpoint}"
           }
}

################## Launch configuration  ###################
resource "aws_launch_configuration" "this" {
  count                       = "${var.create_lc}"       ##This is set to true by default.
  name_prefix                 = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)}-lc : prod-${element(var.product,count.index)}-${element(var.purpose,count.index)}-lc"
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_role.this.name}"
  key_name                    = "${var.key_pair_name}"
  security_groups             = ["${aws_default_security_group.this.id}", "${aws_security_group.this.id}"]
  associate_public_ip_address = "false"
  user_data                   = "${data.template_file.user_data.rendered}"
  enable_monitoring           = "true"
  placement_tenancy           = "default"
  ebs_optimized               = "false"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "${var.root_volume_size}"
    delete_on_termination = "true" 
  }

  lifecycle {
    create_before_destroy = true
  }
}


################## Autoscaling group #################
resource "aws_autoscaling_group" "this" {
  count                     = "${var.create_asg ? 1 : 0}"      ###This is set to 1 by default. So the count value will always be 1.
  name                      = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)}-asg : prod-${element(var.product,count.index)}-${element(var.purpose,count.index)}-asg"
  launch_configuration      = "${var.create_lc ? element(aws_launch_configuration.this.*.name, 0) : var.launch_configuration}"
  vpc_zone_identifier       = ["${lookup(aws_subnet.this-private-sn.subnet_private_ids, element(var.product_roles1, count.index))}","${lookup(aws_subnet.this-private-sn.subnte_private_ids, element(var.prodiuct_roles2, count.index))}"]
  max_size                  = "${element(var.max_size,count.index)}"
  min_size                  = "${element(var.min_size,count.index)}"
  desired_capacity          = "${element(var.desired_capacity,count.index)}"
  health_check_grace_period = "300"
  health_check_type         = "ELB"
  min_elb_capacity          = "0"
  wait_for_elb_capacity     = "false"
  default_cooldown          = "300" 
  force_delete              = "false" 
  termination_policies      = ["Default"]
  enabled_metrics           = [
                "GroupMinSize",
                "GroupMaxSize",
                "GroupDesiredCapacity",
                "GroupInServiceInstances",
                "GroupPendingInstances",
                "GroupStandbyInstances",
                "GroupTerminatingInstances",
                "GroupTotalInstances",
                              ]
  metrics_granularity       = "1Minute"
  wait_for_capacity_timeout = "0"
  protect_from_scale_in     = "false"

tags = [
    {
      key                 = "Name"
      value               = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)} : prod-${element(var.product,count.index)}-${element(var.purpose,count.index)}"
      propagate_at_launch = true
    },
    {
      key                 = "NamePrefix"
      value               = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)} : prod-${element(var.product,count.index)}"
      propagate_at_launch = true
    },
    {
      key                 = "environment"
      value               = "${var.environment == "dev" ? var.environment : "prod"}"
      propagate_at_launch = true
    },
    {
      key                 = "product"
      value               = "${element(var.product,count.index)}"
      propagate_at_launch = true
    },
    {
      key                 = "purpose"
      value               = "${element(var.purpose,count.index}"
      propagate_at_launch = true
    },
  ]

  lifecycle {
      create_before_destroy = true
  }
}

#######auto Scaling ELB Attachment###########
resource "aws_autoscaling_attachment" "this_elb" {
  count                  = 0    ####If this is set to 0, this resource wont be computed.
  autoscaling_group_name = "${aws_autoscaling_group.this.id}"
  elb                    = "${var.elb_id}"
}

#######auto Scaling ELB Attachment###########
resource "aws_autoscaling_attachment" "this_tg" {
  count                  = "${var.tg_count}"    ####If this is set to 0, this resource wont be computed.
  autoscaling_group_name = "${aws_autoscaling_group.this.*.id[count.index]}"
  alb_target_group_arn   = "{aws_lb_target_group.this_tg_alb.arn[count.index]}"
}

##########Auto Scaling Policy############
resource "aws_autoscaling_policy" "this" {
  count                  = "${var.policy_count}"    ####If this is set to 0, this resource wont be computed.
  name                   = "${var.environment == "dev" ? ${var.environment}-${element(var.product,count.index)}-${element(var.purpose,count.index)} : prod-${element(var.product,count.index)}-${element(var.purpose,count.index)}"
  scaling_adjustment     = "${element(var.scaling_adjustment, count.index)}"
  adjustment_type        = "${element(var.adjustment_type, count.index)}"
  cooldown               = "900"
  autoscaling_group_name = "${aws_autoscaling_group.this.*.name[count.index]}"
}

########Cloud Watch Alarm#########
resource "aws_cloudwatch_metric_alarm" "this_low" {
  alarm_name          = "${var.enviroment}-${var.product}-web-cpu-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "This metric monitors low cpu usage"
  alarm_actions       = ["${aws_autoscaling_policy.this.*.arn[count.index]}", "${aws_sns_topic.this.*.arn[count.index]}"]
  dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.this.*.name[count.index]}"
             }
}

resource "aws_cloudwatch_metric_alarm" "this_high" {
  alarm_name          = "${var.environment}-${var.product}-web-cpu-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "75"
  alarm_description   = "This metric monitors high cpu usage"
  alarm_actions       = ["${aws_autoscaling_policy.asp_web_out.arn}", "${aws_sns_topic.asg_topic_web.arn}"]
  dimensions {
        AutoScalingGroupName = "${aws_autoscaling_group.this.*.name[count.index]}"
             }
}

##########Auto Scaling Notification#########
resource "aws_autoscaling_notification" "this" {
  count         = "${var.notify_count}"     ####If this is set to 0, this resource wont be computed.
  group_names   = ["${aws_autoscaling_group.this.name}"]
  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR",
]
  topic_arn     = "${aws_sns_topic.this.*.arn[count.index]}"
}
