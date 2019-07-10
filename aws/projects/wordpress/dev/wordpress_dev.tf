locals {
  wordpress_nonprod_db = [
    {
      db_name          = "wordpress_dev"
      username         = "admin"
      password         = "test1234"
      db_backup_window = "13:00-14:30"
    },
  ]
}

module "wordpress_dev" {
  source = "https://github.com/sathakatheef/wordpress/tree/master/aws/modules"
  
  databases = "${local.wordpress_nonprod_db}"
  
  http_listeners       = "${list(
                            map(
                                "port", 80,
                                "protocol", "HTTP",
                                "redirect_port", 443,
                                "redirect_protocol", "HTTPS",
                                "redirect_path", "/#{path}",
                                "redirect_query", "#{query}",
                                "redirect_status_code", "HTTP_302",
                               ),
  )}"

  https_listeners       = "${list(
                             map(
                                 "port", 443,
                                 "protocol", "HTTPS",
                                 "listener_type", "forward",
                           ),
  )}"
  
  https_listeners_forward_rule    = "${list(
                                      map(
                                         "listener_arn_index", 0,
                                         "rule_type", "forward",
                                         "condition_field", "host-header",
                                         "condition_values", "www.wordpress-dev.com",
                                       ),
  )}"
  
  }
