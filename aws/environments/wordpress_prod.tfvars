#####Global Variables######
    account_name = "test"
    environment  = "prod"
    product      = "wordpress"
    purpose      = ["web"]

####ey Pair Variables#####
    pub_key = "../../../../ssh/amazon-prod.pub"

#######Security Group Variables#####
    sg_purpose = "standard"

######VPC Variables########
    product_roles = ["app","web","db"]
    cidr_block    = "10.26.0.0/16"

#####ACM Variables#####
    cert_body       = "../../../../certs/cert-body.pem"
    cert_privatekey = "../../../../certs/cert-key.pem"
    cert_chain      = "../../../../certs/cert-chain.pem"

#####ASG Variables######
   tpl_file           = "user_data"
   tpl_filepath       = "user_data.sh"
   elb_count          = "0"
   tg_count           = "1"
   policy_count       = "2"
   notify_count       = "1"
   root_volume_size   = "70"
   min_size           = ["2"]
   max_size           = ["4"]
   desired_capacity   = ["2"]
   product_roles1     = "web-a"
   product_roles2     = "web-b"
   key_pair_name      = "amazon-prod"
   create_lc 	      = "1"
   create_asg 	      = "1"
   image_id 	      = "ami-06705195ce845509c"    ####Ubuntu Server 18.04 LTS (HVM), SSD Volume Type
   instance_type      = "r4.large"
   scaling_adjustment = ["-2", "2"]
   adjustment_type    = ["ChangeInCapacity"]

####Load Balancer Variables######
    alb_count 				= "1"
    nlb_count 				= "0"
    alb_product_roles1                  = "pub-a"
    alb_product_roles2                  = "pub-b"
    http_listeners_count 		= "1"
    http_listeners_forward_rule_count   = "0"
    http_listeners_redirect_rule_count  = "0"
    https_listeners_count 		= "1"
    https_listeners_forward_rule_count  = "1"
    https_listeners_redirect_rule_count = "0"
    tcp_listeners_count                 = "0"

#####Target Group Variables#####
    alb_backend_port          = "80"
    alb_backend_protocol      = "http"
    alb_health_check_port     = "80"
    alb_health_check_protocol = "http"

#####RDS Variables######
   databases         = "1"
   engine            = "aurora-mysql"
   port              = "3306"
   max_capacity      = ["2"]
   min_capacity      = ["2"]
   db_product_roles1 = "db-a"
   db_product_roles2 = "db-b"
