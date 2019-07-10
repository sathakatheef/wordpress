######Global Variables##########
variable "region" {default = "ap-southeast-2"}
variable "environment" {}
variable "product" {}
variable "purpose" {}

####Key Pair Variables#####
variable "pub_key" {}

####Security Group Variables#####
varibale "sg_purpose" {}

#####ASG Variables#####
variable "tpl_file_path" {}
variable "tpl_file" {}
variable "elb_count" {}
variable "tg_count" {}
variable "policy_count" {}
variable "notify_count" {}
variable "root_volume_size" {}
variable "min_size" {default = []}
variable "max_size" {default = []}
variable "desired_capacity" {default = []}
variable "product_roles1" {default = []}
variable "product_roles2" {default = []}
variable "create_lc" {}
variable "create_asg" {}
variable "image_id" {}
variable "instance_type" {}
variable "key_pair_name" {}
variable "elb_id" {}
variable "scaling_adjustment" {default = []}
variable "adjustment_type" {default = []}

######VPC Variables#####
variable "cidr_block" {}
variable "product_roles" {default = []}

######ACM Variables######
variable "private_key" {}
variable "certificate_body" {}
variable "certificate_chain" {}

#####Load Balancer Variables#####
variable "logging_enabled" {}
variable "alb_count" {}
variable "nlb_count" {}
variable "alb_product_roles1" {}
variable "alb_product_roles2" {}
variable "nlb_product_roles1" {}
variable "nlb_product_roles2" {}
variable "http_listeners_count" {}
variable "http_listeners" {default = []}
variable "http_listeners_forward_rule_count" {}
variable "http_listeners_forward_rule" {default = []}
variable "http_listeners_redirect_rule_count" {}
variable "http_listeners_redirect_rule" {default = []}
variable "https_listeners_count" {}
variable "https_listeners" {default = []}
variable "https_listeners_forward_rule_count" {}
variable "https_listeners_forward_rule" {default = []}
variable "https_listeners_redirect_rule_count" {}
variable "https_listeners_redirect_rule" {default = []}
variable "tcp_listeners_count" {}
variable "tcp_listeners" {default = []}

#####Target Group Variables#####
variable "alb_backend_port" {}
variable "alb_backend_protocol" {}
variable "nlb_backend_port" {}
variable "nlb_backend_protocol" {}
variable "alb_health_check_port" {}
variable "alb_health_check_protocol" {}
variable "nlb_health_check_port" {}
variable "nlb_health_check_protocol" {}

####RDS Variables######
variable "databases" {}
variable "engine" {}
variable "db_name" {}
variable "username" {}
variable "password" {}
variable "port" {}
variable "db_backup_window" {}
variable "max_capacity" {default = []}
variable "min_capacity" {default = []}
variable "db_product_roles1" {}
variable "db_product_roles2" {}
